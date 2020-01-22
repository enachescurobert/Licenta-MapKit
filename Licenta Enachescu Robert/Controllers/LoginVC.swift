//
//  LoginVC.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 19/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
  
//  MARK: - IBOutlets
  @IBOutlet weak var loginTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  
//  MARK: - Properties
  let loginToMap = "loginToMap"
  
//  MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
        
    // Remove the user if he logs out of the system
    let listener = Auth.auth().addStateDidChangeListener{
      auth, user in
      if user != nil {
        self.performSegue(withIdentifier: self.loginToMap, sender: nil)
      }
    }
    Auth.auth().removeStateDidChangeListener(listener)
  }
  
//  MARK: - IBActions
  @IBAction func loginDidTouch(_ sender: Any) {
    if loginTF.text == "" || passwordTF.text == "" {
      showAlert(titleToShow: "Error", messageToShow: "You must fill out all fields")
    } else {
      Auth.auth().signIn(withEmail: loginTF.text!, password: passwordTF.text!, completion: {
        authDataResult, error in
        if error != nil {
          self.showAlert(titleToShow: "Error", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
        }
        
        if authDataResult != nil {
          self.performSegue(withIdentifier: self.loginToMap, sender: nil)
        }
        
      })
    }
  }
  
  fileprivate func showAlert(titleToShow: String, messageToShow: String) {
    
    let alert = UIAlertController(title: titleToShow, message: messageToShow, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
      NSLog("The \"OK\" alert occured.")
    }))
    self.present(alert, animated: true, completion: nil)
    
  }
  
}
