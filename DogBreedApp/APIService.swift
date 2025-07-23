//
//  APIService.swift
//  DogBreedsApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import Foundation

class APIService {
    private let baseURL = "https://api.thedogapi.com/v1"
    private let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
        // Configure URLCache for images
        let cache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 100_000_000, diskPath: "dog_images")
        session.configuration.urlCache = cache
    }
    
    // Fetch paginated list of breeds
    func fetchBreeds(page: Int, limit: Int = 20) async throws -> [Breed] {
        let cacheFile = cacheDir.appendingPathComponent("breeds_page_\(page).json")
        
        // Try cache first
        if let cachedData = try? Data(contentsOf: cacheFile),
           let cachedBreeds = try? JSONDecoder().decode([Breed].self, from: cachedData) {
            var breeds = cachedBreeds
            await withTaskGroup(of: (Int, URL?).self) { group in
                for breed in breeds {
                    group.addTask { (breed.id, await self.fetchBreedImage(breedID: breed.id, useCache: true)) }
                }
                for await (id, imageURL) in group {
                    if let index = breeds.firstIndex(where: { $0.id == id }) {
                        breeds[index].imageURL = imageURL
                    }
                }
            }
            return breeds
        }
        
        // Fetch from API
        let url = URL(string: "\(baseURL)/breeds?page=\(page)&limit=\(limit)")!
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        var breeds = try JSONDecoder().decode([Breed].self, from: data)
        
        // Fetch images
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
        // Cache the JSON
        try? JSONEncoder().encode(breeds).write(to: cacheFile)
        return breeds
    }
    
    // Search breeds by name
    func searchBreeds(query: String) async throws -> [Breed] {
        let queryHash = query.hashValue.description
        let cacheFile = cacheDir.appendingPathComponent("search_query_\(queryHash).json")
        
        // Try cache first
        if let cachedData = try? Data(contentsOf: cacheFile),
           let cachedBreeds = try? JSONDecoder().decode([Breed].self, from: cachedData) {
            var breeds = cachedBreeds
            await withTaskGroup(of: (Int, URL?).self) { group in
                for breed in breeds {
                    group.addTask { (breed.id, await self.fetchBreedImage(breedID: breed.id, useCache: true)) }
                }
                for await (id, imageURL) in group {
                    if let index = breeds.firstIndex(where: { $0.id == id }) {
                        breeds[index].imageURL = imageURL
                    }
                }
            }
            return breeds
        }
        
        // Fetch from API
        let url = URL(string: "\(baseURL)/breeds/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        var breeds = try JSONDecoder().decode([Breed].self, from: data)
        
        // Fetch images
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
        // Cache the JSON
        try? JSONEncoder().encode(breeds).write(to: cacheFile)
        return breeds
    }
    
    // Fetch one image for a breed
    private func fetchBreedImage(breedID: Int, useCache: Bool = false) async -> URL? {
        let url = URL(string: "\(baseURL)/images/search?breed_ids=\(breedID)&limit=1")!
        do {
            let request = URLRequest(url: url, cachePolicy: useCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData)
            let (data, _) = try await session.data(for: request)
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
