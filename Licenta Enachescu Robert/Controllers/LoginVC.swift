//
//  LoginVC.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 19/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
  
  // MARK: - Properties
  var userItemsReference = Database.database().reference(withPath: "Users")
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //      MARK: - Upload to Firebase
//          let childRef = Database.database().reference(withPath: "Users")
//          let values = ["email": "testescu@gmail.com",
//                        "engineStarted": false,
//                        "scooter": false,
//                        "username": "testescu"
//            ] as [String : Any]
//
//          childRef.setValue(values)
    
    //      MARK: - Read from Database
    userItemsReference.observe(.value, with: {
      snapshot in
      let values = snapshot.value as! [String:AnyObject]
      let email = values["email"] as! String
      let username = values["username"] as! String
      let scooter = values["scooter"] as! Bool
      let engineStarted = values["engineStarted"] as! Bool
      
      print("email: \(email)")
      print("username: \(username)")
      print("is a scooter: \(scooter)")
      if scooter {
        print("the engine is on: \(engineStarted)")
      }
      
    })
    
//    userItemsReference.child("email").observe(.value, with: {
//      snapshot in
//      print(snapshot)
//    })
    
  }
  
}
