import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showCurrentQuestion(step: QuizStepViewModel)
    func showQuizResults(result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButtonsEnabled(_ isEnabled: Bool)
}
