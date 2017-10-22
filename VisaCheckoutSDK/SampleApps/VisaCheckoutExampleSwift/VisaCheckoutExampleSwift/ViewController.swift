/**
 Copyright © 2017 Visa. All rights reserved.
 */

import UIKit
import VisaCheckoutSDK

class ViewController: UIViewController {
    @IBOutlet var checkoutButton: VisaCheckoutButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// See the documentation/headers for `PurchaseInfo` for
        /// various ways to customize the purchase experience.
        let purchaseInfo = PurchaseInfo(total: 22.09, currency: .usd)
        purchaseInfo.reviewAction = .pay
        
        checkoutButton.onCheckout(purchaseInfo: purchaseInfo) { result in
            switch result.statusCode {
            case .success:
                print("Encrypted key: \(String(describing: result.encryptedKey))")
                print("Payment data: \(String(describing: result.encryptedPaymentData))")
            case .userCancelled:
                print("Payment cancelled by the user")
            default:
                break
            }
        }
    }
}
