//
//  UserModel.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 20/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import Foundation
import Firebase

struct UserModel {
  
  let key: String
  let email: String
  let username: String
  let ref: DatabaseReference?
  var engineStarted: Bool
  var scooter: Bool

  
  init(email: String, username: String, scooter: Bool, engineStarted: Bool = false, key: String = "") {
    self.key = key
    self.email = email
    self.username = username
    self.scooter = scooter
    self.engineStarted = engineStarted
    self.ref = nil
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    email = snapshotValue["email"] as! String
    username = snapshotValue["username"] as! String
    scooter = snapshotValue["scooter"] as! Bool
    engineStarted = snapshotValue["engineStarted"] as! Bool
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "email": email,
      "username": username,
      "scooter": scooter,
      "engineStarted": engineStarted
    ]
  }
  
}
