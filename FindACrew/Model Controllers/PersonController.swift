//
//  PersonController.swift
//  FindACrew
//
//  Created by Ben Gohlke on 5/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class PersonController {
    
    var crew: [Person] = []

    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    private let baseURL = URL(string: "https://lambdaswapi.herokuapp.com")!
    private lazy var peopleURL = URL(string: "/api/people", relativeTo: baseURL)!
    
    func searchForPeopleWith(searchTerm: String, completion: @escaping () -> Void) {
        // Step 1: Build endpoint URL with query items
        var urlComponents = URLComponents(url: peopleURL, resolvingAgainstBaseURL: true)
        let searchTermQueryItem = URLQueryItem(name: "search", value: searchTerm)
        urlComponents?.queryItems = [searchTermQueryItem]
        
        guard let requestURL = urlComponents?.url else {
            print("request URL is nil")
            completion()
            return
        }
        
        // Step 2: Create URL Request
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        // Step 3: Create URL Task
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            // Handle error first
            if let error = error {
                print("Error fetching data: \(error)")
                completion()
                return
            }
            
            guard let self = self else { completion(); return }
            
            // Handle Data Optionality
            guard let data = data else {
                print("no data returned from data task.")
                completion()
                return
            }
            
            // Create Decoder
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Decode and add objects to array
            do {
                let personSearch = try jsonDecoder.decode(PersonSearch.self, from: data)
                self.crew.append(contentsOf: personSearch.results)
            } catch {
                print("Unable to decode data into object of type PersonSearch: \(error)")
            }
            
            completion()
        }
        
        // Step 4: Run URL Task
        task.resume()
    }
}
