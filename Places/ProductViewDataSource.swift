//
//  ProductViewDataSource.swift
//  Places
//
//  Created by Jeremy Hon on 10/21/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Foundation

class ProductViewDataSource: ViewController, ProductViewDelegate {
  
  override func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
    let annotationView = ProductView()
    annotationView.annotation = viewForAnnotation
    annotationView.delegate = self
    annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
    
    return annotationView
  }
  
  func didTouch(productView: ProductView) {
    if let annotation = productView.annotation as? Place {
      let placesLoader = PlacesLoader()
      placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
        
        if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
          annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
          annotation.website = infoDict.object(forKey: "website") as? String
          
          self.showInfoView(forPlace: annotation)
        }
      }
      
    }
  }
}
