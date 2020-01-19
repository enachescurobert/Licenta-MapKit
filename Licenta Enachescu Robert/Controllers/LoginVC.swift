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

    override func viewDidLoad() {
        super.viewDidLoad()

      let rootRef = Database.database().reference()
      let itemsRef = rootRef.child("Users")
      let emailRef = itemsRef.child("email")
      
      let childRef = Database.database().reference(withPath: "Users") // or:
      let values = ["email": "testescu@gmail.com",
                    "eningeStarted": false,
                    "scooter": false,
                    "username": "testescu"
        ] as [String : Any]
      childRef.setValue(values)
      
//      https://www.raywenderlich.com/4203-beginning-firebase/lessons/6
      print(rootRef.key)
      print(childRef.key)
      print(itemsRef.key)
      print(emailRef.key)
      
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
