import UIKit


final class AlertPresenter {
    public weak var controller: MovieQuizViewController?
    
    func show(in: MovieQuizViewController, model result: AlertModel) {

        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            
            result.comletion()
        }
        
        alert.addAction(action)

        self.controller?.present(alert, animated: true)
    }
}
