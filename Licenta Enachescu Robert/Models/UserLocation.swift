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
  let user_id: String?
  
  init(geoPoint: GeoPoint, user: User, user_id: String) {
    self.geoPoint = geoPoint
    self.user = user
    self.user_id = user_id
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    let geoPoint = data["geoPoint"] as? GeoPoint
    let user = data["user"] as? [String : Any]
    let user_id = document.documentID

    self.geoPoint = geoPoint
    self.user = User(data: user!)
    self.user_id = user_id

  }
  
}
