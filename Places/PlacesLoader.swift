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

import Foundation
import CoreLocation
import Alamofire

class NetworkManager {
  
  var manager: SessionManager!
  var apiURL = "https://sandbox.api.visa.com/merchantlocator/v1/locator"
  let user = "R8PEZ5ZV0D1EQZW5XSAF215EI8yW4YgQssEtCnIuo8AbwPwL4"
  let password = "mtCN8GYTdEke8Jr3d2p0ZB9MeU3j7hx8q3"
  var apiKey = "UjhQRVo1WlYwRDFFUVpXNVhTQUYyMTVFSTh5VzRZZ1Fzc0V0Q25JdW84QWJ3UHdMNDptdENOOEdZVGRFa2U4SnIzZDJwMFpCOU1lVTNqN2h4OHEz"
  
  init() {
    let cert = PKCS12.init(mainBundleResource: "cert", resourceType: "p12", password: "");
    
    let configuration = URLSessionConfiguration.default
    manager = Alamofire.SessionManager(configuration: configuration)
    manager.delegate.sessionDidReceiveChallenge = { session, challenge in
      if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
        return (URLSession.AuthChallengeDisposition.useCredential, cert.urlCredential());
      }
      if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
        return (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!));
      }
      return (URLSession.AuthChallengeDisposition.performDefaultHandling, Optional.none);
    }
  }
  
  func getOffers() {
    
  }
  
  func getStores(location: CLLocation, radius: Int = 30, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    print("Load pois")
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    print("lat", latitude, ", lng", longitude)
    
    let parameters: Parameters = [
      "searchOptions": [
        "matchScore": "true",
        "matchIndicators": "true",
        "maxRecords": "5",
        "wildcard": "*"
      ],
      "responseAttrList": [
        "GNLOCATOR"
      ],
      "searchAttrList": [
        "distanceUnit": "M",
        "distance": "2",
        "longitude": longitude,
        "latitude": latitude,
        "merchantCountryCode": "840",
        "merchantName": "*"
      ],
      "header": [
        "startIndex": "0",
        "requestMessageId": "Request_001",
        "messageDateTime": "2017-10-21T23:15:52.903"
      ]
    ]
    
    var headers: HTTPHeaders = [
      "Accept": "application/json"
    ]
    
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
      headers[authorizationHeader.key] = authorizationHeader.value
    }
    
    self.manager
      .request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
      .responseJSON { response in
          let dict: NSDictionary = [
            "results": [
              [
                "name": "Ralph Lauren",
                "reference": "1",
                "address": "123 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0003,
                "lng":longitude
              ],[
                "name": "Kate Spade",
                "reference": "2",
                "address": "124 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0006,
                "lng":longitude+0.0003
              ],[
                "name": "COACH",
                "reference": "3",
                "address": "125 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0009,
                "lng":longitude-0.0003
              ]
            ]
          ]
          handler(dict, nil)
    }
  }
}

struct PlacesLoader {
  let apiURL = "https://maps.googleapis.com/maps/api/place/"
  let apiKey = "AIzaSyCy2oE6AUns55yY8Xwy4IFDZwS3Xmbyz8c"
  
  func loadPOIS(location: CLLocation, radius: Int = 30, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    print("Load pois")
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    
    let uri = apiURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&sensor=true&types=establishment&key=\(apiKey)"
    
    let url = URL(string: uri)!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: url) { data, response, error in
      if let error = error {
        print(error)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          print(data!)
          
          do {
            let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = responseObject as? NSDictionary else {
              return
            }
            
            handler(responseDict, nil)
            
          } catch let error as NSError {
            handler(nil, error)
          }
        }
      }
    }
    
    dataTask.resume()
  }
  
  func loadDetailInformation(forPlace: Place, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    
    let uri = apiURL + "details/json?reference=\(forPlace.reference)&sensor=true&key=\(apiKey)"
    
    let url = URL(string: uri)!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: url) { data, response, error in
      if let error = error {
        print(error)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          print(data!)
          
          do {
            let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = responseObject as? NSDictionary else {
              return
            }
            
            handler(responseDict, nil)
            
          } catch let error as NSError {
            handler(nil, error)
          }
        }
      }
    }
    
    dataTask.resume()
    
  }
}
