import Foundation
import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveQuestion(_ question: QuizQuestion?)
}

protocol QuestionFactory {
    func requestNextQuestion()
}

final class QuestionFactoryImpl {
    
    private weak var delegate: QuestionFactoryDelegate?
    private var questions: [QuizQuestion] = []
    
    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
        loadQuestionsFromJSON()
    }
    
    private func loadQuestionsFromJSON() {
        if let path = Bundle.main.path(forResource: "top250MoviesIMDB", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let top = try? JSONDecoder().decode(Top.self, from: data) {
            
            let movies = top.items
            
            print("Movies count: \(movies.count)")
            
            // Create a dispatch group to wait for all asynchronous tasks to complete
            let dispatchGroup = DispatchGroup()
            
            movies.forEach { movie in
                
                guard let imageURL = URL(string: movie.image) else {
                    print("Invalid image URL: \(movie.image)")
                    return
                }
                
                // Enter the dispatch group before starting the download task
                dispatchGroup.enter()
                
                downloadImage(from: imageURL) { [weak self] (image) in
                    guard let self = self else { return }
                    
                    let randomComparisonRank = Int.random(in: 1...10)
                    let correctAnswer = true
                    let text = "Рейтинг этого фильма больше чем \(randomComparisonRank)?"
                    
                    let quizQuestion = QuizQuestion(text: text, imageURL: imageURL, correctAnswer: correctAnswer)
                    self.questions.append(quizQuestion)
                    
                    // Leave the dispatch group when the download and processing are complete
                    dispatchGroup.leave()
                }
            }
            
            // Notify when all tasks in the dispatch group are complete
            dispatchGroup.notify(queue: .main) {
                print("Questions count: \(self.questions.count)")
            }
            
        } else {
            print("Failed to load or decode JSON file")
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
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
}

extension QuestionFactoryImpl: QuestionFactory {
    func requestNextQuestion() {
        DispatchQueue.main.async {
            if let question = self.questions.randomElement() {
                print("Selected question: \(question)")
                self.delegate?.didReceiveQuestion(question)
            } else {
                print("No questions available or unexpected error.")
            }
        }
    }
}
