/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

import CoreLocation
//import MapKit

class ViewController: UIViewController {
  
  fileprivate var places = [Place]()
  fileprivate var places1 = [Place]()
  var arViewController: ARViewController!
  var arViewController1: ARViewController!
  var startedLoadingPOIs = false
  var networkMgr = NetworkManager()
  var loaded = false
  var secondScreen = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let location = CLLocation(latitude: 36.12256531, longitude: -115.16667458)
    
    if !startedLoadingPOIs {
      startedLoadingPOIs = true
      networkMgr.getStores(location: location, radius: 1000) { placesDict, error in
        if let dict = placesDict {
          guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
          var count = 0
          for placeDict in placesArray {
            let latitude = placeDict.value(forKeyPath: "lat") as! CLLocationDegrees
            let longitude = placeDict.value(forKeyPath: "lng") as! CLLocationDegrees
            let reference = placeDict.object(forKey: "reference") as! String
            let name = placeDict.object(forKey: "name") as! String
            let address = placeDict.object(forKey: "address") as! String
            let tag = placeDict.object(forKey: "tag") as! Int
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let place = Place(location: location, reference: reference, name: name, address: address, tag: tag)
            if count < 3 {
              self.places.append(place)
              
            }
            else {
              self.places1.append(place)
            }
            count += 1
            print("Places: ", self.places)
            print("Places1: ", self.places1)
          }
        }
      }
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if loaded == false {
      showARController("")
      loaded = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showARController(_ sender: Any) {
    print("second screen", secondScreen)
    print("Creating arViewController")
    self.arViewController = ARViewController()
    self.arViewController.dataSource = self
    self.arViewController.maxDistance = 0
    self.arViewController.maxVisibleAnnotations = 30
    self.arViewController.maxVerticalLevel = 1
    self.arViewController.headingSmoothingFactor = 0.05
    
    self.arViewController.trackingManager.userDistanceFilter = 25
    self.arViewController.trackingManager.reloadDistanceFilter = 75
    self.arViewController.setAnnotations(places)
    self.arViewController.uiOptions.debugEnabled = false
    self.arViewController.uiOptions.closeButtonEnabled = true
    
    //creating second ARView (for in store items listing)
    print("Creating arViewController1")
    self.arViewController1 = ARViewController()
    self.arViewController1.dataSource = self
    self.arViewController1.maxDistance = 0
    self.arViewController1.maxVisibleAnnotations = 30
    self.arViewController1.maxVerticalLevel = 1
    self.arViewController1.headingSmoothingFactor = 0.05
    
    self.arViewController1.trackingManager.userDistanceFilter = 25
    self.arViewController1.trackingManager.reloadDistanceFilter = 75
    self.arViewController1.setAnnotations(places1)
    self.arViewController1.uiOptions.debugEnabled = false
    self.arViewController1.uiOptions.closeButtonEnabled = true
    
    //    self.arViewController = arViewController
    //    self.arViewController1 = arViewController1
    
    print("SWIPING LEFT")
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
    swipeLeft.direction = .left
    self.arViewController.addGestureRecognizer(gesture: swipeLeft)
    self.arViewController1.addGestureRecognizer(gesture: swipeLeft)
    
    print("SWIPING RIGHT")
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
    swipeRight.direction = .right
    self.arViewController.addGestureRecognizer(gesture: swipeRight)
    self.arViewController1.addGestureRecognizer(gesture: swipeRight)
    
    print("SWIPING UP")
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
    swipeUp.direction = .up
    self.arViewController.addGestureRecognizer(gesture: swipeUp)
    self.arViewController1.addGestureRecognizer(gesture: swipeUp)
    
    print("SWIPING DOWN")
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
    swipeDown.direction = .down
    self.arViewController.addGestureRecognizer(gesture: swipeDown)
    self.arViewController1.addGestureRecognizer(gesture: swipeDown)
    
    print("Presenting arViewController")
    if self.secondScreen {
      self.present(self.arViewController1, animated: true, completion: nil)
    } else {
      self.present(self.arViewController, animated: true, completion: nil)
    }
    
    
    let checkoutLabel = UILabel(frame: CGRect(x: 0, y: self.view.bounds.size.height - 50, width: self.view.bounds.size.width/2, height: 50))
    checkoutLabel.textAlignment = .left
    checkoutLabel.backgroundColor = UIColor(red:0.0, green:1.0, blue:0.0, alpha: 0.7)
    checkoutLabel.textColor = UIColor.white
    checkoutLabel.text = "Checkout"
    checkoutLabel.textAlignment = .center
    checkoutLabel.isUserInteractionEnabled = true
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(goCheckout))
    checkoutLabel.addGestureRecognizer(tapGR)
    self.arViewController1.view.addSubview(checkoutLabel)
    
    let scanLabel = UILabel(frame: CGRect(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 50, width: self.view.bounds.size.width/2, height: 50))
    scanLabel.textAlignment = .right
    scanLabel.backgroundColor = UIColor(red:1.0, green:0.0, blue:0.0, alpha: 0.7)
    scanLabel.textColor = UIColor.white
    scanLabel.text = "Scan"
    scanLabel.textAlignment = .center
    scanLabel.isUserInteractionEnabled = true
    let scantapGR = UITapGestureRecognizer(target: self, action: #selector(goScan))
    scanLabel.addGestureRecognizer(scantapGR)
    self.arViewController1.view.addSubview(scanLabel)
    
    var filterLabel: UILabel?
    filterLabel = UILabel(frame: CGRect(x: 5, y: 10, width: 116,height: 30))
    filterLabel?.text = ""
    filterLabel?.addImage(imageName: "my size.png")
    filterLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
    filterLabel?.isUserInteractionEnabled = true
    let filtertapGR = UITapGestureRecognizer(target: self, action: #selector(goFilter))
    filterLabel?.addGestureRecognizer(filtertapGR)
    self.arViewController1.view.addSubview(filterLabel!)
  }
  
  func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
    if gesture.direction == UISwipeGestureRecognizerDirection.right {
      print("Swipe Right")
    }
    else if gesture.direction == UISwipeGestureRecognizerDirection.left {
      print("Swipe Left")
    }
    else if gesture.direction == UISwipeGestureRecognizerDirection.up {
      print("Swipe Up")
    }
    else if gesture.direction == UISwipeGestureRecognizerDirection.down {
      print("Swipe Down")
    }
  }
  
  func showInfoView(forPlace place: Place) {
    let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
    if self.secondScreen {
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
        
      }
      alert.addAction(okAction)
      
      arViewController1.present(alert, animated: true, completion: nil)
    }
    else {
      let okAction = UIAlertAction(title: "ENTER STORE", style: UIAlertActionStyle.default) { (_) -> Void in
        self.secondScreen = true
        self.arViewController.presentingViewController?.dismiss(animated: false, completion: nil)
        self.present(self.arViewController1, animated: false, completion: nil)
      }
      let backAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) -> Void in
        print("cancel")
      }
      alert.addAction(okAction)
      alert.addAction(backAction)
      
      arViewController.present(alert, animated: true, completion: nil)
    }
    
  }
  
  func goToSecondScreen() {
    self.secondScreen = true
  }
  
  func goFilter() {
    print("Filtering")
    self.places1 = Array(self.places1.prefix(2))
    print("Filtered Places1: ", self.places1.description)
    if let viewWithTag = self.arViewController1.view.viewWithTag(5) {
      viewWithTag.removeFromSuperview()
      print("Tag 5 removed")
    }
    else {
      print("Tag 5 not found")
    }
    
    if let viewWithTag = self.arViewController1.view.viewWithTag(4) {
      print("Tag 4 removed")
      viewWithTag.removeFromSuperview()
    }
    else {
      print("Tag 4 not found")
    }
  }
  
  func goScan() {
    print("scanning")
    self.arViewController1.presentingViewController?.dismiss(animated: true, completion: nil)
    
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as! QRScannerViewController
    vc.setOrigin(vc: self)
    self.present(vc, animated: true)
  }
  
  func goCheckout() {
    print("checkout")
    self.arViewController1.presentingViewController?.dismiss(animated: true, completion: nil)
    
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
    self.present(vc, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print(segue.identifier!)
  }
}

extension ViewController: ARDataSource {
  func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
    let annotationView = AnnotationView()
    annotationView.annotation = viewForAnnotation
    annotationView.delegate = self
    if let annotation = viewForAnnotation as? Place {
      if annotation.address == "nil" {
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
        return annotationView
      }
    }
    annotationView.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
    
    return annotationView
  }
}

extension ViewController: AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView) {
    if let annotation = annotationView.annotation as? Place {
      networkMgr.loadDetailInformation(forPlace: annotation) { resultDict, error in
        annotation.offers = resultDict?.object(forKey: "offers") as? String
        self.showInfoView(forPlace: annotation)
      }
    }
  }
}
