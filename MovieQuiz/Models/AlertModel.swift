//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Алан Мун on 18.11.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var buttonAction: () -> Void
}
