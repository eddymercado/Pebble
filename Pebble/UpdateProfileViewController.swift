//
//  UpdateProfileViewController.swift
//  Pebble
//
//  Created by Tesna Thomas on 11/10/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class UpdateProfileViewController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadExistingProfileData()
    }
    
    func loadExistingProfileData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {

                if let base64String = document.get("profilePic") as? String {
                    // Convert the Base64 string to UIImage

                    if let image = self.decodeBase64ToImage(base64String) {
                        self.profileImageView.image = image // Set the decoded image in an UIImageView
                    }
                }
                
                if let username = document.get("username") as? String {
                    self.usernameTextField.text = username
                } else {
                    print("Username not found or not a string")
                }
                
                if let bio = document.get("bio") as? String {
                    self.bioTextField.text = bio
                } else {
                    print("bio not found or not a string")
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    
    @IBAction func uploadPhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @IBAction func saveProfileChanges(_ sender: UIButton) {
        if let image = profileImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.5) {
            let base64String = imageData.base64EncodedString()
            
            let db = Firestore.firestore()
            guard let userId = Auth.auth().currentUser?.uid else { return }

            db.collection("users").document(userId).updateData(["profilePic": base64String]) { error in
                if let error = error {
                    print("Failed to save profile pic to Firestore: \(error.localizedDescription)")
                } else {
                    print("Profile picture successfully saved in Firestore")
                }
            }
        }

        // Firestore Save
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData([
            "username": usernameTextField.text ?? "",
            "bio": bioTextField.text ?? ""
        ]) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully!")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

}
