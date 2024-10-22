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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        // if username is valid login/ segue to browse events
        
        
        
        
        // if not alert no account found please sign up
        /*
         if username not found
         let controller = UIAlertController(
             title: "Username not found or password does not match username",
             message: "Please try verify your password or Create an account!",
             preferredStyle: .alert)
         
         // if password does not match username ?? if we decide to do this
         */
        
        performSegue(withIdentifier: "startUpToBrowseEventsPage", sender: self)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "startUpToSignUp", sender: self)
    }

}
