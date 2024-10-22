//
//  SignUpInfoVC.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit

class SignUpInfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpNextButton(_ sender: Any) {
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
        
        performSegue(withIdentifier: "signUpPageToProfilePic", sender: self)
    }


}
