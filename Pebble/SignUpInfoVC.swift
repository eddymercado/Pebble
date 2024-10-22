//
//  SignUpInfoVC.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit
import FirebaseAuth

class SignUpInfoVC: UIViewController {
    
    
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var fullNameField: UITextField!
    
    @IBOutlet weak var emailAddressField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var dateOfBirthField: UITextField!
    
    @IBOutlet weak var zipCodeFIeld: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorMessage.text = ""
    }
    

    @IBAction func signUpNextButton(_ sender: Any) {
        Auth.auth().createUser(withEmail: usernameField.text!, password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
                self.performSegue(withIdentifier: "signUpPageToProfilePic", sender: self)
            }
        }
    /*
        // create a new user
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                self.errorMessage.text = ""
            }
        }
     */
        
        
    }


}
