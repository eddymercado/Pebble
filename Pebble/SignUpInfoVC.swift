//
//  SignUpInfoVC.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//
// balls

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

class SignUpInfoVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var emailAddressField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var dateOfBirthField: UITextField!
    
    @IBOutlet weak var zipCodeFIeld: UITextField!
    
    
    let db = Firestore.firestore()
//    let profilePicture = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("this was called")
        emailAddressField.text = "no"
        passwordField.text = " yes"
    }

    @IBAction func signUpNextButton(_ sender: Any) {
        guard let email = emailAddressField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let firstName = firstNameField.text, !firstName.isEmpty,
              let username = usernameField.text, !username.isEmpty,
              let phoneNumber = phoneNumberField.text, !phoneNumber.isEmpty,
              let dateOfBirth = dateOfBirthField.text, !dateOfBirth.isEmpty,
              let lastName = lastName.text, !lastName.isEmpty,
              let zipCode = zipCodeFIeld.text, !zipCode.isEmpty else {
            showAlert(title: "Please fill in all fields", message: "")

            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError? {
                self.showAlert(title: "Error", message: "\(error.localizedDescription)")
            } else {
                // User signed up successfully
                guard let userId = authResult?.user.uid else { return }

                // Create user data to store in Firestore
                let userData: [String: Any] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "username": username,
                    "email": email,
                    "phoneNumber": phoneNumber,
                    "dateOfBirth": dateOfBirth,
                    "zipCode": zipCode,
                ]
                
                self.db.collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                    } else {
                        Analytics.setUserProperty(zipCode, forName: "Zip Code")
                        Analytics.setUserProperty(phoneNumber, forName: "Phone Number")
                        Analytics.setUserProperty(dateOfBirth, forName: "Date of Birth")
                        Analytics.setUserProperty(username, forName: "Username")
                        Analytics.setUserProperty(firstName, forName: "First Name")
                        Analytics.setUserProperty(lastName, forName: "Last Name")
                        self.performSegue(withIdentifier: "signUpPageToProfilePic", sender: self)
                    }
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
}
