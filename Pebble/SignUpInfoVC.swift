//
//  SignUpInfoVC.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics

//import FirebaseFirestoreInternal

class SignUpInfoVC: UIViewController {
    
    
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var fullNameField: UITextField!
    
    @IBOutlet weak var emailAddressField: UITextField!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var dateOfBirthField: UITextField!
    
    @IBOutlet weak var zipCodeFIeld: UITextField!
    
    @IBOutlet weak var errorMessage: UILabel!
    
//    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorMessage.text = ""
    }
    

    @IBAction func signUpNextButton(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailAddressField.text!, password: passwordField.text!) {
            (authResult,error) in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
            } else {
                
                Analytics.setUserProperty(self.zipCodeFIeld.text?.isEmpty == false ? self.zipCodeFIeld.text : nil, forName: "Zip Code")
                
                
                self.errorMessage.text = ""
                self.performSegue(withIdentifier: "signUpPageToProfilePic", sender: self)
            }
        }
        
        
        // Ensure all fields are filled
            guard let email = emailAddressField.text, !email.isEmpty,
                  let password = passwordField.text, !password.isEmpty,
                  let fullName = fullNameField.text, !fullName.isEmpty,
                  let username = usernameField.text, !username.isEmpty,
                  let phoneNumber = phoneNumberField.text, !phoneNumber.isEmpty,
                  let dateOfBirth = dateOfBirthField.text, !dateOfBirth.isEmpty,
                  let zipCode = zipCodeFIeld.text, !zipCode.isEmpty else {
                errorMessage.text = "Please fill in all fields."
                return
            }

            // Create user with Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error as NSError? {
                    self.errorMessage.text = "\(error.localizedDescription)"
                } else {
                    // User signed up successfully
                    guard let userId = authResult?.user.uid else { return }

                    // Create user data to store in Firestore
                    let userData: [String: Any] = [
                        "fullName": fullName,
                        "username": username,
                        "email": email,
                        "phoneNumber": phoneNumber,
                        "dateOfBirth": dateOfBirth,
                        "zipCode": zipCode
                    ]
                    
                    // Store user information in Firestore
//                    self.db.collection("users").document(userId).setData(userData) { error in
//                        if let error = error {
//                            self.errorMessage.text = "Error saving user data: \(error.localizedDescription)"
//                        } else {
//                            // Set zip code as a user property for Firebase Analytics
//                            Analytics.setUserProperty(zipCode, forName: "Zip Code")
//                            
//                            // Optionally set additional properties for Analytics
//                            Analytics.setUserProperty(phoneNumber, forName: "Phone Number")
//                            Analytics.setUserProperty(dateOfBirth, forName: "Date of Birth")
//                            Analytics.setUserProperty(username, forName: "Username")
//
//                            self.errorMessage.text = ""
//                            // Proceed to the next screen
//                            self.performSegue(withIdentifier: "signUpPageToProfilePic", sender: self)
//                        }
//                    }
                }
            }
    }
}
