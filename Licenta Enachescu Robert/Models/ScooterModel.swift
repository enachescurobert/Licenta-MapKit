//
//  ScooterModel.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 22/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class ScooterModel: NSObject {
  
  let location: CLLocation
  let name: String
  let imageName: String
  
  init(latitude: Double, longitude: Double, name: String, imageName: String) {
    self.location = CLLocation(latitude: latitude, longitude: longitude)
    self.name = name
    self.imageName = imageName
  }
  
}

extension ScooterModel: MKAnnotation {
  
  var coordinate: CLLocationCoordinate2D {
    get {
      return location.coordinate
    }
  }
  
  var title: String? {
    get {
      return name
    }
  }
  
}
