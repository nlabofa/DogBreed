//
//  BreedsView.swift
//  DogBreedApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import SwiftUI

struct BreedsView: View {
    @State private var breeds: [Breed] = []
    @State private var page = 0
    @State private var isLoading = false
    @State private var isGridView = false  // False = list, True = grid
    
    var body: some View {
        VStack {
            if isGridView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                        ForEach(breeds) { breed in
                            NavigationLink(destination: BreedDetailView(breed: breed)) {
                                BreedGridItem(breed: breed)
                            }
                            .onAppear {
                                if breed.id == breeds.last?.id {
                                    loadMoreBreeds()
                                }
                            }
                        }
                    }
                    if isLoading {
                        ProgressView()
                    }
                }
            } else {
                List(breeds) { breed in
                    NavigationLink(destination: BreedDetailView(breed: breed)) {
                        BreedListItem(breed: breed)
                    }
                    .onAppear {
                        if breed.id == breeds.last?.id {
                            loadMoreBreeds()
                        }
                    }
                }
                if isLoading {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Dog Breeds")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isGridView.toggle() }) {
                    Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                }
            }
        }
        .onAppear {
            loadMoreBreeds()
        }
    }
    
    private func loadMoreBreeds() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let newBreeds = try await APIService().fetchBreeds(page: page)
                breeds.append(contentsOf: newBreeds)
                page += 1
            } catch {
                print("Error loading breeds: \(error)")
            }
            isLoading = false
        }
    }
}

// Helper views for list/grid items
struct BreedListItem: View {
    let breed: Breed
    
    var body: some View {
        HStack {
            if let url = breed.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit().frame(width: 50, height: 50)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "photo").frame(width: 50, height: 50)
            }
            Text(breed.name)
        }
    }
}

struct BreedGridItem: View {
    let breed: Breed
    
    var body: some View {
        VStack {
            if let url = breed.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit().frame(height: 150)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "photo").frame(height: 150)
            }
            Text(breed.name)
                .font(.caption)
        }
    }
}

#Preview {
    BreedsView()
}
