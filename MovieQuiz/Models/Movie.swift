//
//  Movie.swift
//  MovieQuiz
//
//  Created by Алан Мун on 18.11.2023.
//

import Foundation

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}

struct Movie: Codable {
    let id: String
    let rank: String
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let crew: String
    let imDbRating: String
    let imDbRatingCount: String
}

struct Top: Decodable {
    let items: [Movie]
    let errorMessage: String
}

func loadTopFromJSON() -> Top? {
    if let path = Bundle.main.path(forResource: "top250MoviesIMDB", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            let top = try decoder.decode(Top.self, from: data)
            return top
        } catch {
            print("Error loading top data:", error.localizedDescription)
            return nil
        }
    }
    return nil
}
