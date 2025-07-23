//
//  BreedDetail.swift
//  DogBreedApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import SwiftUI

struct BreedDetailView: View {
    let breed: Breed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let url = breed.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit().frame(height: 200)
                } placeholder: {
                    ProgressView()
                }
            }
            Text("Name: \(breed.name)").font(.title)
            if let group = breed.breed_group {
                Text("Category: \(group)")
            }
            if let origin = breed.origin {
                Text("Origin: \(origin)")
            }
            if let temperament = breed.temperament {
                Text("Temperament: \(temperament)")
            }
            Spacer()
        }
        .padding()
        .navigationTitle(breed.name)
    }
}

#Preview {
    BreedDetailView(breed: Breed(id: 1, name: "Sample", breed_group: "Group", origin: "Origin", temperament: "Friendly"))
}
