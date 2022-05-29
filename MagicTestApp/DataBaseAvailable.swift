import Foundation
import UIKit

protocol DataBaseAbailable {
    var dataBase: DataBase? { get }
}

extension DataBaseAbailable {
    var dataBase: DataBase? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.dataBase
    }
}
