import Foundation
import UIKit

protocol APIRequestControllerAvailable {
    var apiRequestController: ApiRequestController? { get }
}

extension APIRequestControllerAvailable {
    var apiRequestController: ApiRequestController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.apiRequestController
    }
}
