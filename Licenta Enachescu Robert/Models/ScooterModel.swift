//
//  ScooterModel.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 22/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation
import CoreLocation

class ScooterModel {
  
  let location: CLLocation
  let name: String
  let imageName: String
  
  init(latitude: Double, longitude: Double, name: String, imageName: String) {
    self.location = CLLocation(latitude: latitude, longitude: longitude)
    self.name = name
    self.imageName = imageName
  }
  
}
