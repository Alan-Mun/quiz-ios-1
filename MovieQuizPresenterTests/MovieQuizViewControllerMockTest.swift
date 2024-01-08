import XCTest
@testable import MovieQuiz

class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func showCurrentQuestion(step: QuizStepViewModel) {
        
    }
    
    func showQuizResults(result: QuizResultsViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

