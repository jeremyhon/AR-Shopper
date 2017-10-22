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
                "reference": "ralph.png",
                "address": "123 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0003,
                "lng":longitude
              ],[
                "name": "Kate Spade",
                "reference": "kate.png",
                "address": "124 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0006,
                "lng":longitude+0.0003
              ],[
                "name": "COACH",
                "reference": "coach.png",
                "address": "125 The Venetian, 3355 S Las Vegas Blvd, Las Vegas",
                "lat":latitude+0.0009,
                "lng":longitude-0.0003
              ],[
                "name": "Shirt",
                "reference": "shirt.png",
                "address": "nil",
//                "lat":latitude+0.0003,
//                "lng":longitude
                "lat":latitude+0.00031,
                "lng":longitude+0.0001
              ],[
                "name": "Polo",
                "reference": "polo.png",
                "address": "nil",
//                "lat":latitude+0.0003,
//                "lng":longitude
                "lat":latitude+0.00033,
                "lng":longitude+0.00008
              ],[
                "name": "Jeans",
                "reference": "jeans.png",
                "address": "nil",
//                "lat":latitude+0.0003,
//                "lng":longitude
                "lat":latitude+0.00035,
                "lng":longitude-0.00005
              ],[
                "name": "Sweater",
                "reference": "sweater.png",
                "address": "nil",
//                "lat":latitude+0.0003,
//                "lng":longitude
                "lat":latitude+0.00037,
                "lng":longitude
              ]
            ]
          ]
          handler(dict, nil)
    }
  }
  
  func loadDetailInformation(forPlace: Place, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    var dict:NSDictionary = [
      "offers": "This is an offer"
    ]
    if forPlace.placeName == "Ralph Lauren" {
      dict = [
        "offers": "Offer for Ralph Lauren"
      ]
    }
    handler(dict, nil)
  }
}
