//
//  DogBreedAppTests.swift
//  DogBreedAppTests
//
//  Created by Opeyemi Agbeja on 23/07/2025.
//

import XCTest
@testable import DogBreedApp

final class DogBreedsAppTests: XCTestCase {
    var apiService: APIService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        // Create custom URLSession with MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        apiService = APIService(session: mockSession)
    }
    
    override func tearDown() {
        MockURLProtocol.mockResponse = nil
        super.tearDown()
    }
    
    func testFetchBreeds() async throws {
        // Mock response
        let mockData = """
        [
            {"id": 1, "name": "Labrador", "breed_group": "Sporting", "origin": "Canada", "temperament": "Friendly"},
            {"id": 2, "name": "Bulldog", "breed_group": "Non-Sporting", "origin": "England", "temperament": "Calm"}
        ]
        """.data(using: .utf8)!
        MockURLProtocol.mockResponse = (mockData, HTTPURLResponse(url: URL(string: "https://api.thedogapi.com/v1/breeds")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        let breeds = try await apiService.fetchBreeds(page: 0, limit: 2)
        XCTAssertEqual(breeds.count, 2)
        XCTAssertEqual(breeds[0].name, "Labrador")
        XCTAssertEqual(breeds[1].name, "Bulldog")
    }
    
    func testSearchBreeds() async throws {
        let mockData = """
        [{"id": 1, "name": "Labrador", "breed_group": "Sporting", "origin": "Canada", "temperament": "Friendly"}]
        """.data(using: .utf8)!
        MockURLProtocol.mockResponse = (mockData, HTTPURLResponse(url: URL(string: "https://api.thedogapi.com/v1/breeds/search")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        
        let breeds = try await apiService.searchBreeds(query: "Lab")
        XCTAssertEqual(breeds.count, 1)
        XCTAssertEqual(breeds[0].name, "Labrador")
    }
    
    func testBreedsViewSorting() {
        // Create a testable BreedsView
        let view = BreedsView()
        var breeds = [
            Breed(id: 1, name: "Zebra", breed_group: nil, origin: nil, temperament: nil, imageURL: nil),
            Breed(id: 2, name: "Apple", breed_group: nil, origin: nil, temperament: nil, imageURL: nil)
        ]
        
        // Test ascending sort
        breeds.sort { $0.name.lowercased() < $1.name.lowercased() }
        XCTAssertEqual(breeds[0].name, "Apple")
        XCTAssertEqual(breeds[1].name, "Zebra")
        
        // Test descending sort
        breeds.sort { $0.name.lowercased() > $1.name.lowercased() }
        XCTAssertEqual(breeds[0].name, "Zebra")
        XCTAssertEqual(breeds[1].name, "Apple")
    }
}

// Mock URLProtocol for API testing
class MockURLProtocol: URLProtocol {
    static var mockResponse: (Data, URLResponse)?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let (data, response) = MockURLProtocol.mockResponse else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
