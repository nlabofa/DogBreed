//
//  ContentView.swift
//  DogBreedApp
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                BreedsView()
            }
            .tabItem {
                Label("Breeds", systemImage: "list.bullet")
            }
            
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
    }
}

#Preview {
    ContentView()
}
