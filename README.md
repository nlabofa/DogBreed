# Dog Breed App

A SwiftUI-based iOS application that allows users to browse, search, and learn about various dog breeds.

## Features

- **Browse Dog Breeds**: View a comprehensive list of dog breeds with essential information
- **Grid and List Views**: Toggle between grid and list views for breed browsing
- **Search Functionality**: Find specific dog breeds by name
- **Detailed Information**: Access detailed information about each breed including:
  - Origin
  - Temperament
  - Breed group
  - High-quality images
- **Offline Support**: Caching system for viewing breeds even without internet connection

## Technologies Used

- **Swift 5+**: Modern Swift programming language
- **SwiftUI**: Apple's declarative UI framework
- **Async/Await**: For clean, efficient network calls
- **URLSession**: For API communication
- **Codable**: For JSON parsing
- **The Dog API**: As the data source ([thedogapi.com](https://thedogapi.com/))

## App Architecture

The app follows a clean architecture approach:

- **Models**: `Breed.swift` defines the data structure
- **Views**: Separate view files for different screens (BreedsView, SearchView, BreedDetail)
- **Services**: `APIService.swift` handles all network communication

## Getting Started

### Prerequisites

- Xcode 14.0+
- iOS 16.0+ (for device deployment)

### Installation

1. Clone this repository

   ```bash
   git clone https://github.com/yourusername/DogBreedApp.git
   ```

2. Open `DogBreedApp.xcodeproj` in Xcode
3. Build and run the application in the simulator or on a physical device

## Usage

- **Browse Breeds**: Use the "Breeds" tab to view all available dog breeds
- **Search**: Use the "Search" tab to find specific breeds by name
- **View Details**: Tap on any breed to see detailed information
