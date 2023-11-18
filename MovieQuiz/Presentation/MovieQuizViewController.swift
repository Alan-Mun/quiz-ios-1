import UIKit
import Foundation

final class MovieQuizViewController: UIViewController {
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var alertPresentor: AlertPresenter?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactoryImpl(delegate: self)
            alertPresentor = AlertPresenterImpl(viewController: self)
            statisticService = StatisticServiceImpl()

            if let savedQuestion = loadSavedQuestion() {
                currentQuestion = savedQuestion
                let viewModel = convert(model: savedQuestion)
                show(quiz: viewModel)
            } else {
                questionFactory?.requestNextQuestion()
            }

            yesButton.isEnabled = true
            noButton.isEnabled = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let savedQuestionKey = "savedQuestion"

    func saveQuestion(_ question: QuizQuestion) {
        do {
            let encodedData = try JSONEncoder().encode(question)
            UserDefaults.standard.set(encodedData, forKey: savedQuestionKey)
        } catch {
            print("Error encoding question: \(error.localizedDescription)")
        }
    }

    func loadSavedQuestion() -> QuizQuestion? {
        if let savedData = UserDefaults.standard.data(forKey: savedQuestionKey) {
            do {
                let question = try JSONDecoder().decode(QuizQuestion.self, from: savedData)
                return question
            } catch {
                print("Error decoding question: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    private var isGameInProgress = false

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            removeBorderColor()
            
            // Проверка, чтобы избежать повторного вызова
            if !isGameInProgress {
                isGameInProgress = true
                questionFactory?.requestNextQuestion()
            }
            
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }

    private func showFinalResults() {
        isGameInProgress = false
        statisticService?.store(correct: correctAnswers, total: questionsAmount)

        if let currentQuestion = currentQuestion {
            saveQuestion(currentQuestion)
        }

        let alertModel = AlertModel(
            title: "Игра окончена!",
            message: makeResultsMessage(),
            buttonText: "ОК",
            buttonAction: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
                self?.removeBorderColor()
                self?.yesButton.isEnabled = true
                self?.noButton.isEnabled = true
            }
        )

        alertPresentor?.show(alertModel: alertModel)
    }



    
    private func makeResultsMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccurancyLine = "Средняя точность: \(accuracy)%"
        
        let components: [String] = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccurancyLine
        ]
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        print("Downloading image from URL: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            } 

            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }

    private func show(quiz step: QuizStepViewModel) {
        downloadImage(from: step.imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.textLabel.text = step.question
                self?.counterLabel.text = step.questionNumber
            }
        }
    }

    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.removeBorderColor()
            self.questionFactory?.requestNextQuestion()
            self.showNextQuestionOrResults()
        }
    }

    
    private func removeBorderColor() {
            imageView.layer.borderColor = UIColor.clear.cgColor
        }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            imageURL: model.imageURL,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }


    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveQuestion(_ question: QuizQuestion?) {
        if let question = question {
            print("Received question with imageURL: \(question.imageURL)")
            self.currentQuestion = question
            let viewModel = self.convert(model: question)
            self.show(quiz: viewModel)
        }
    }
}
