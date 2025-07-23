//
//  Breed.swift
//  DogBreedsApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import Foundation

struct Breed: Identifiable, Codable {
    let id: Int
    let name: String
    let breed_group: String? 
    let origin: String?
    let temperament: String?
    var imageURL: URL?  
    
    // Coding keys to match API JSON exactly
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breed_group
        case origin
        case temperament
    }
}
