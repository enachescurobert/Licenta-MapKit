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
  var users: [UserModel] = []
  var userItemsReference = Database.database().reference(withPath: "Users")
  var childName = "Aurelian"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //      MARK: - Upload to Firebase
    let userRef = self.userItemsReference.child(childName)
    let values: [String: Any] = ["email": "testescu@gmail.com",
                            "engineStarted": false,
                            "scooter": false,
                            "username": "testescu"
                ]
    userRef.setValue(values)
    
    //      MARK: - Read from Database
//    Getting the entire Object
    userItemsReference.child(childName).observe(.value, with: {
      snapshot in
      print(snapshot)
    })

//    Parsing all elements
    userItemsReference.child(childName).observe(.value, with: {
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
        
  }
  
}
