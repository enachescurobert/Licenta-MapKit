//
//  User.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 21/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct User {
  
  let email: String
  let user_id: String
  var username: String?
  var scooter: Bool?
  var engineStarted: Bool?
  var engineStatedAt: Date?
  
  init(authData: User) {
    user_id = authData.user_id
    email = authData.email
  }
  
  init(user_id: String, email: String) {
    self.user_id = user_id
    self.email = email
  }
  
  init?(data: [String: Any]) {

    let email = data["email"] as? String
    let user_id = data["user_id"] as? String
    let username = data["username"] as? String
    let scooter = data["scooter"] as? Bool
    let engineStarted = data["engineStarted"] as? Bool
    let engineStatedAt = data["engineStartedAt"] as? Date

    self.email = email ?? "not found"
    self.user_id = user_id ?? "not found"
    self.username = username
    self.scooter = scooter
    self.engineStarted = engineStarted
    self.engineStatedAt = engineStatedAt
  }
  
}
