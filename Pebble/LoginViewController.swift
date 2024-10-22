//
//  LoginViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorMessage.text = ""
    }
    
    @IBAction func loginButton(_ sender: Any) {
        // if username is valid login/ segue to browse events
        guard let email = usernameField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            self.errorMessage.text = "Please enter both email and password."
            return
        }
        
        Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                self.performSegue(withIdentifier: "startUpToBrowseEventsPage", sender: self)
            }
        }
        
        
        // if not alert no account found please sign up
        /*
         if username not found
         let controller = UIAlertController(
             title: "Username not found or password does not match username",
             message: "Please try verify your password or Create an account!",
             preferredStyle: .alert)
         
         // if password does not match username ?? if we decide to do this
         */
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "startUpToSignUp", sender: self)
    }

}
