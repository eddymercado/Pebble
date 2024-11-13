//
//  updateInfoViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 11/12/24.
//



// add back button

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreInternal


class updateInfoViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var updateEmailAddressTextField: UITextField!
    
    @IBOutlet weak var updateFirstNameTextField: UITextField!
    
    @IBOutlet weak var updateLastNameTextField: UITextField!
    
    @IBOutlet weak var updatePhoneNumberTextField: UITextField!
    
    
    @IBOutlet weak var successfulOrNot: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExistingProfileData()
        
        
    }
    
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateEmailAddressTextField.text = ""
        updateFirstNameTextField.text = ""
        updateLastNameTextField.text = ""
        updatePhoneNumberTextField.text = ""
    }
    
    func loadExistingProfileData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                
                // email address
                if let email = document.get("email") as? String {
                    self.updateEmailAddressTextField.text = email
                } else {
                    print("email address not found or not a string")
                }
                
                // first name
                if let firstName = document.get("firstName") as? String {
                    self.updateFirstNameTextField.text = firstName
                } else {
                    print("first name not found or not a string")
                }
                // last name
                if let lastName = document.get("lastName") as? String {
                    self.updateLastNameTextField.text = lastName
                } else {
                    print("last name not found or not a string")
                }
                // phone number
                if let phoneNumber = document.get("phoneNumber") as? String {
                    self.updatePhoneNumberTextField.text = phoneNumber
                } else {
                    print("phone number not found or not a string")
                }
            }
        }
    }
    
    
    @IBAction func saveUpdatedProfileInfoButton(_ sender: Any) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData([
            "email": updateEmailAddressTextField.text ?? "",
            "firstName": updateFirstNameTextField.text ?? "",
            "lastName": updateLastNameTextField.text ?? "",
            "phoneNumber": updatePhoneNumberTextField.text ?? ""
        ]) { error in
            if let error = error {
                self.successfulOrNot.text = (error.localizedDescription)
            } else {
                self.successfulOrNot.text = "Profile updated successfully!"
            }
        }
        
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        // are you sure you want to delete
        
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        
        // Delete from Firestore
        self.db.collection("users").document(userId).delete { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
                return
            } else {
                // Delete from Firebase Authentication
                user.delete { error in
                    if let error = error {
                        self?.showAlert(title: "Error", message: "\(error.localizedDescription)")
                    } else {
                        // Redirect to login screen after successful deletion
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let loginVC = storyboard.instantiateViewController(withIdentifier: "loginNav") as? UINavigationController {
                            loginVC.modalPresentationStyle = .fullScreen
                            self?.present(loginVC, animated: true, completion: nil)
                        }
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
    
