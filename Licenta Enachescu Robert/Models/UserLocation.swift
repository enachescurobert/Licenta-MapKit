//
//  UserLocation.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 13/02/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct UserLocation {
  
  let geoPoint: GeoPoint?
  let user: User?
  
  init(geoPoint: GeoPoint, user: User) {
    self.geoPoint = geoPoint
    self.user = user
  }
  
  init?(data: [String: Any]) {
    let geoPoint = data["geoPoint"] as? GeoPoint
    let user = data["user"] as? [String : Any]

    self.geoPoint = geoPoint
    self.user = User(data: user!)

  }
  
}
