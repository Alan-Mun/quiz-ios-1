//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Алан Мун on 18.11.2023.
//

import Foundation

struct QuizQuestion: Codable {
    let text: String
    let imageURL: URL
    let correctAnswer: Bool
    
    enum CodingKeys: String, CodingKey {
        case text
        case imageURL
        case correctAnswer
    }
}

