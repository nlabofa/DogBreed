//
//  SearchView.swift
//  DogBreedApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var results: [Breed] = []
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            List(results) { breed in
                NavigationLink(destination: BreedDetailView(breed: breed)) {
                    VStack(alignment: .leading) {
                        Text(breed.name).font(.headline)
                        if let group = breed.breed_group {
                            Text("Group: \(group)")
                        }
                        if let origin = breed.origin {
                            Text("Origin: \(origin)")
                        }
                        if let url = breed.imageURL {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit().frame(height: 100)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search Breeds")
        .onChange(of: searchText) { newValue in
            if newValue.count > 2 {  // Debounce: search after 3 chars
                searchBreeds(query: newValue)
            } else {
                results = []
            }
        }
    }
    
    private func searchBreeds(query: String) {
        Task {
            do {
                results = try await APIService().searchBreeds(query: query)
            } catch {
                print("Search error: \(error)")
            }
        }
    }
}

// Custom SearchBar (SwiftUI doesn't have built-in, so we make one)
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search by breed name", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
            }
        }
        .padding()
    }
}

#Preview {
    SearchView()
}
