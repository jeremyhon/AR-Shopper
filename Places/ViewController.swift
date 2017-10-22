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
    arViewController = ARViewController()
    arViewController.dataSource = self
    arViewController.maxDistance = 0
    arViewController.maxVisibleAnnotations = 30
    arViewController.maxVerticalLevel = 5
    arViewController.headingSmoothingFactor = 0.05
    
    arViewController.trackingManager.userDistanceFilter = 25
    arViewController.trackingManager.reloadDistanceFilter = 75
    arViewController.setAnnotations(places)
    arViewController.uiOptions.debugEnabled = false
    arViewController.uiOptions.closeButtonEnabled = true
    
    //creating second ARView (for in store items listing)
    print("Creating arViewController1")
    arViewController1 = ARViewController()
    arViewController1.dataSource = self
    arViewController1.maxDistance = 0
    arViewController1.maxVisibleAnnotations = 30
    arViewController1.maxVerticalLevel = 5
    arViewController1.headingSmoothingFactor = 0.05
    
    arViewController1.trackingManager.userDistanceFilter = 25
    arViewController1.trackingManager.reloadDistanceFilter = 75
    arViewController1.setAnnotations(places1)
    arViewController1.uiOptions.debugEnabled = false
    arViewController1.uiOptions.closeButtonEnabled = true
    
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
    self.present(arViewController, animated: true, completion: nil)
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
        
        self.arViewController.presentingViewController?.dismiss(animated: true, completion: nil)
        self.present(self.arViewController1, animated: true, completion: nil)
      }
      print("Adding okAction")
      alert.addAction(okAction)
      
      arViewController.present(alert, animated: true, completion: nil)
      self.secondScreen = true
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
      if location.horizontalAccuracy < 100 {
        manager.stopUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mapView.region = region
        
        if !startedLoadingPOIs {
          startedLoadingPOIs = true
          // let loader = PlacesLoader()
          // loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
          networkMgr.getStores(location: location, radius: 1000) { placesDict, error in
            if let dict = placesDict {
              guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
              var count = 0
              for placeDict in placesArray {
                // let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                // let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                let latitude = placeDict.value(forKeyPath: "lat") as! CLLocationDegrees
                let longitude = placeDict.value(forKeyPath: "lng") as! CLLocationDegrees
                let reference = placeDict.object(forKey: "reference") as! String
                let name = placeDict.object(forKey: "name") as! String
                // let address = placeDict.object(forKey: "vicinity") as! String
                let address = placeDict.object(forKey: "address") as! String
                print(placeDict)
                
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let place = Place(location: location, reference: reference, name: name, address: address)
                if count < 5 {
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
              print("Place: " + self.places.description)
              print("Place1: " + self.places1.description)
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
    annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
    
    return annotationView
  }
}

extension ViewController: AnnotationViewDelegate {
  func didTouch(annotationView: AnnotationView) {
    if let annotation = annotationView.annotation as? Place {
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
