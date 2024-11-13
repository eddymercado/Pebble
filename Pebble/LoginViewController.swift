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

class LoginViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure any subsequent navigations use fullScreen when coming back
        self.navigationController?.modalPresentationStyle = .fullScreen
        
        // Clear the text fields when the view appears
        usernameField.text = ""
        passwordField.text = ""
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
            DispatchQueue.main.async {
                if (error as NSError?) != nil {
                    self.showAlert(title: "Email or Password is incorrect", message: "Retry credentials or create an account!")
                } else {
                    self.performSegue(withIdentifier: "startUpToBrowseEventsPage", sender: self)
                }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Assuming SignUpViewController is in Main storyboard
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpInfoVC") as? SignUpInfoVC {
            // This ensures that the navigation is pushed and remains full screen
            self.navigationController?.pushViewController(signUpVC, animated: true)
        }
    }

}
