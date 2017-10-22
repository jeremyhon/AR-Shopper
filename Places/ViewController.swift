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
import MapKit

class ViewController: UIViewController {
  
  fileprivate var places = [Place]()
  fileprivate var places1 = [Place]()
  fileprivate let locationManager = CLLocationManager()
  @IBOutlet weak var mapView: MKMapView!
  var arViewController: ARViewController!
  var arViewController1: ARViewController!
  var startedLoadingPOIs = false
  var networkMgr = NetworkManager()
  var secondScreen = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    locationManager.requestWhenInUseAuthorization()
    mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showARController(_ sender: Any) {
    print("Creating arViewController")
    self.arViewController = ARViewController()
    self.arViewController.dataSource = self
    self.arViewController.maxDistance = 0
    self.arViewController.maxVisibleAnnotations = 30
    self.arViewController.maxVerticalLevel = 5
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
    self.arViewController1.maxVerticalLevel = 5
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
    self.present(self.arViewController, animated: true, completion: nil)
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
      print("YES!")
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (_) -> Void in
        
      }
      print("Adding okAction")
      alert.addAction(okAction)
      
      arViewController1.present(alert, animated: true, completion: nil)
    }
    else {
      print("NO!")
      let okAction = UIAlertAction(title: "ENTER STORE", style: UIAlertActionStyle.default) { (_) -> Void in
        self.secondScreen = true
        self.arViewController.presentingViewController?.dismiss(animated: false, completion: nil)
        self.present(self.arViewController1, animated: false, completion: nil)
        print("presenting product view")
      }
      let backAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) -> Void in
        print("cancel")
      }
      alert.addAction(okAction)
      alert.addAction(backAction)
      
      arViewController.present(alert, animated: true, completion: nil)
    }
    
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if locations.count > 0 {
      let location = locations.last!
      //      let location = CLLocation(latitude: 36.12256531, longitude: -115.16667458)
      
      if location.horizontalAccuracy < 100 {
        manager.stopUpdatingLocation()
        print(location)
        let span = MKCoordinateSpan(latitudeDelta: 0.010, longitudeDelta: 0.010)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mapView.region = region
        
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
                
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let place = Place(location: location, reference: reference, name: name, address: address)
                if count < 3 {
                  self.places.append(place)
                  
                }
                else {
                  self.places1.append(place)
                }
                count += 1
                let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
                DispatchQueue.main.async {
                  self.mapView.addAnnotation(annotation)
                }
              }
            }
          }
        }
      }
    }
  }
}

extension ViewController: ARDataSource {
  func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
    let annotationView = AnnotationView()
    annotationView.annotation = viewForAnnotation
    annotationView.delegate = self
    if let annotation = viewForAnnotation as? Place {
      print(annotation.address)
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
    print("touched")
    if let annotation = annotationView.annotation as? Place {
      networkMgr.loadDetailInformation(forPlace: annotation) { resultDict, error in
        annotation.offers = resultDict?.object(forKey: "offers") as? String
        print("annotation offer: \(annotation.offers ?? "no offers")")
        self.showInfoView(forPlace: annotation)
        
      }
      
    }
  }
}
