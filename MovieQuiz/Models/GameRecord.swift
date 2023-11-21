//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Алан Мун on 18.11.2023.
//

import Foundation

struct GameRecord: Codable, Comparable {
    static func < (oldResult: GameRecord, newResult: GameRecord) -> Bool {
        oldResult.correct < newResult.correct
    }
    
    let correct: Int
    let total: Int
    let date: Date
   
}

