//
//  CheckoutViewController.swift
//  Places
//
//  Created by Jia Wern Yong on 21/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import VisaCheckoutSDK

class CheckoutViewController: UIViewController {
      
    @IBOutlet var checkoutButton: VisaCheckoutButton!
    override func viewDidLoad() {
      super.viewDidLoad()
      print("Payment cancelled by the user 1")
      let purchaseInfo = PurchaseInfo(total: 22.09, currency: .usd)
      purchaseInfo.reviewAction = .pay
      print("Payment cancelled by the user 2")

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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
