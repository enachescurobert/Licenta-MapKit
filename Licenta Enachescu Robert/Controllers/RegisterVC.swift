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
  
  //  MARK: - Properties
  let goToMap = "goToMap"
  
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
      
      Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) {
        authDataResult, error in
        
        if error != nil {
          if let errorCode = AuthErrorCode(rawValue: error!._code) {
            switch errorCode {
            case .weakPassword:
              print("Please provice a strong password")
              self.showAlert(titleToShow: "ERROR", messageToShow: "Please provide a strong password")
            default:
              print(error?.localizedDescription ?? "Error")
              self.showAlert(titleToShow: "ERROR", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
            }
            
          }
        }
        
        if authDataResult != nil {
          authDataResult?.user.sendEmailVerification() {
            error in
            if error != nil {
              self.showAlert(titleToShow: "ERROR", messageToShow: "Error: \(error?.localizedDescription ?? "error")")
            } else {
              Auth.auth().signIn(withEmail: self.emailTF.text!, password: self.passwordTF.text!)
              
              self.showAlert(titleToShow: "Done", messageToShow: "You will receive an confirmation email soon. You'll have limited access for now.", performTheSegue: true)

            }
          }
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
  
  fileprivate func showAlert(titleToShow: String, messageToShow: String, performTheSegue: Bool) {
    
    let alert = UIAlertController(title: titleToShow, message: messageToShow, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
      if performTheSegue {
        self.performSegue(withIdentifier: self.goToMap, sender: nil)
      }
    }))
    self.present(alert, animated: true, completion: nil)
    
  }

  
}
