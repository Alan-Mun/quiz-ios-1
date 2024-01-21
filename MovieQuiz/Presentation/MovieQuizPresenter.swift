import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var correctAnswers = 0
    private var questionsAmount = 10
    private var currentQuestionIndex = 0
    private var statisticPresenter: StatisticService = StatisticServiceImplementation()
    
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Private Methods
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
        
    private func buttonClicked(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {return}
        
        proceedWithAnswer(isCorrect: givenAnswer ==   currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            
            viewController?.showAlertPresenter()
            
        } else {
            
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    // MARK: - Public Methods
    func yesButtonClicked() {
        buttonClicked(givenAnswer: true)
    }
    
    func noButtonClicked() {
        buttonClicked(givenAnswer: false)
    }
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func statisticAlertStrings() -> String {
        
        statisticPresenter.store(correct: correctAnswers, total: questionsAmount)
        
        guard let bestGame = statisticPresenter.gameRecord else {return "nil"}
        
        let text = "Ваш результат \(correctAnswers)/\(questionsAmount)"
        let totalGamesString = "Количество сыгранных квизов: \(statisticPresenter.gamesCount)"
        let bestGameString = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let accuracyOfAnswers = "Средяя точность: \(String(format: "%.2f", statisticPresenter.totalAccuracy))%"
        
        let statisticAlert = [text, totalGamesString, bestGameString, accuracyOfAnswers].joined(separator: "\n")
        
        return statisticAlert
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        viewController?.areButtonsEnable(bool: true)
        viewController?.unshowImageBorederColor()
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.alertPresenter.controller = viewController
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
