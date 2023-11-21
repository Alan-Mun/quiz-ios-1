import UIKit

extension UIColor {
        static var ypGreen: UIColor { UIColor(named: "YP Green") ?? UIColor.green }
        static var ypRed: UIColor { UIColor(named: "YP Red") ?? UIColor.red }
        static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black}
        static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.darkGray }
        static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
        static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white}
     }

extension UIColor {
    var ypRed: CGColor {
        return UIColor(red: 0.96, green: 0.42 ,blue: 0.42 , alpha: 1.00).cgColor
    }
    var ypGreen: CGColor {
        return UIColor(red: 0.38, green: 0.76, blue: 0.56, alpha: 1.0).cgColor
    }
}
