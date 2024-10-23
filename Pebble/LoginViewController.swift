//
//  LoginViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

let db = Firestore.firestore()

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        // if username is valid login/ segue to browse events
        guard let email = usernameField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Please enter both email and password", message: "")
            return
        }
        
        Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) {
            (authResult, error) in
            if (error as NSError?) != nil {
                self.showAlert(title: "Email or Password is incorrect", message: "Retry credentials or create an account!")
            } else {
                self.performSegue(withIdentifier: "startUpToBrowseEventsPage", sender: self)
            }
        }
    }
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "startUpToSignUp", sender: self)
    }

}
