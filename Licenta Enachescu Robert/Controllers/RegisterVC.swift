//
//  RegisterVC.swift
//  Licenta Enachescu Robert
//
//  Created by Robert Enachescu on 19/01/2020.
//  Copyright © 2020 Enachescu Robert. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterVC: UIViewController {
  
  //  MARK: - IBOutlets
  @IBOutlet weak var emailTF: UITextField!
  @IBOutlet weak var passwordTF: UITextField!
  @IBOutlet weak var confirmPasswordTF: UITextField!
  
  //  MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  //  MARK: - IBActions
  @IBAction func register(_ sender: Any) {
    if emailTF.text == "" ||
      passwordTF.text == "" ||
      confirmPasswordTF.text == "" {
      showAlert(titleToShow: "Error", messageToShow: "You must fill out all fields.")
    } else if passwordTF.text != confirmPasswordTF.text {
      showAlert(titleToShow: "Error", messageToShow: "Passwords did not match.")
    } else {
      
      Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!, completion: {
        user, error in
        if error != nil {
          self.showAlert(titleToShow: "ERROR", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
        }
        if user != nil {

        }
      })
      
      Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) {
        authDataResult, error in
        if error != nil {
          print(error?.localizedDescription ?? "Error")
          self.showAlert(titleToShow: "ERROR", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
        }
        if authDataResult != nil {
          authDataResult?.user.sendEmailVerification() {
            error in
          self.showAlert(titleToShow: "ERROR", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
          }
        }
        if !(authDataResult?.user.isEmailVerified ?? false) {
          self.showAlert(titleToShow: "Done", messageToShow: "You will receive an confirmation email soon")
        }
      }
      
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
