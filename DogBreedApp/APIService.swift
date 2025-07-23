//
//  APIService.swift
//  DogBreedsApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import Foundation

class APIService {
    private let baseURL = "https://api.thedogapi.com/v1"
    
    // Fetch paginated list of breeds
    func fetchBreeds(page: Int, limit: Int = 20) async throws -> [Breed] {
        let url = URL(string: "\(baseURL)/breeds?page=\(page)&limit=\(limit)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        var breeds = try JSONDecoder().decode([Breed].self, from: data)
        
        // Fetch image for each breed asynchronously
        await withTaskGroup(of: (Int, URL?).self) { group in
            for breed in breeds {
                group.addTask { (breed.id, await self.fetchBreedImage(breedID: breed.id)) }
            }
            for await (id, imageURL) in group {
                if let index = breeds.firstIndex(where: { $0.id == id }) {
                    breeds[index].imageURL = imageURL
                }
            }
        }
        return breeds
    }
    
    // Search breeds by name
    func searchBreeds(query: String) async throws -> [Breed] {
        let url = URL(string: "\(baseURL)/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        let (data, _) = try await URLSession.shared.data(from: url)
        var breeds = try JSONDecoder().decode([Breed].self, from: data)
        
        // Fetch images similarly
        await withTaskGroup(of: (Int, URL?).self) { group in
            for breed in breeds {
                group.addTask { (breed.id, await self.fetchBreedImage(breedID: breed.id)) }
            }
            for await (id, imageURL) in group {
                if let index = breeds.firstIndex(where: { $0.id == id }) {
                    breeds[index].imageURL = imageURL
                }
            }
        }
        return breeds
    }
    
    // Fetch one image for a breed
    private func fetchBreedImage(breedID: Int) async -> URL? {
        let url = URL(string: "\(baseURL)/images/search?breed_ids=\(breedID)&limit=1")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let images = try JSONDecoder().decode([DogImage].self, from: data)
            return URL(string: images.first?.url ?? "")
        } catch {
            print("Image fetch error: \(error)")
            return nil
        }
    }
}

// Helper struct for image response
struct DogImage: Codable {
    let url: String
}
