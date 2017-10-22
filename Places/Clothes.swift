//
//  Clothes.swift
//  Places
//
//  Created by Jia Wern Yong on 21/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

class Clothes  {
  var name: String
  var photo: UIImage?
  var price: Int
  
  init?(name: String, photo: UIImage?, price: Int){
    self.name = name
    self.photo = photo
    self.price = price
    
    if name.isEmpty || price < 0  {
      return nil
    }
    
  }
}

