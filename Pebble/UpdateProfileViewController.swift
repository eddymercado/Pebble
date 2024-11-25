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
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let db = Firestore.firestore()
    var isUpdatingBackgroundImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadExistingProfileData()
        let backButton = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: "Back To Profile Page",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue, // Single underline
                .foregroundColor: UIColor.blue                     // Text color
            ]
        )
        backButton.setAttributedTitle(attributedTitle, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 15, y: 55, width: 200, height: 30)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadBackgroundPhotoTapped))
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func backButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "ProfilePage") as? ProfilePage {
            updateProfileVC.modalPresentationStyle = .fullScreen
            self.present(updateProfileVC, animated: true, completion: nil)
        }
    }
    
    func loadExistingProfileData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {

                if let profileBase64String = document.get("profilePic") as? String,
                   let profileImage = self.decodeBase64ToImage(profileBase64String) {
                    self.profileImageView.image = profileImage
                }
                
                if let backgroundBase64String = document.get("backgroundPic") as? String,
                   let backgroundImage = self.decodeBase64ToImage(backgroundBase64String) {
                    self.backgroundImageView.image = backgroundImage
                }
                
                if let username = document.get("username") as? String {
                    self.usernameTextField.text = username
                } else {
                    print("Username not found or not a string")
                }
                
                if let bio = document.get("bio") as? String {
                    self.bioTextField.text = bio
                } else {
                    print("Bio not found or not a string")
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
        isUpdatingBackgroundImage = false
        presentImagePicker()
    }
    
    @IBAction func uploadBackgroundButtonTapped(_ sender: UIButton) {
        isUpdatingBackgroundImage = true
        presentImagePicker()
    }
    
    func presentImagePicker() {
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
        
        // Save background picture
        if let backgroundImage = backgroundImageView.image,
           let backgroundImageData = backgroundImage.jpegData(compressionQuality: 0.5) {
            let backgroundBase64String = backgroundImageData.base64EncodedString()
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            db.collection("users").document(userId).updateData(["backgroundPic": backgroundBase64String]) { error in
                if let error = error {
                    print("Failed to save background pic to Firestore: \(error.localizedDescription)")
                } else {
                    print("Background picture successfully saved in Firestore")
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
        if let selectedImage = info[.editedImage] as? UIImage {
            if isUpdatingBackgroundImage {
                backgroundImageView.image = selectedImage
            } else {
                profileImageView.image = selectedImage
            }
        } else if let selectedImage = info[.originalImage] as? UIImage {
            if isUpdatingBackgroundImage {
                backgroundImageView.image = selectedImage
            } else {
                profileImageView.image = selectedImage
            }
        }
        isUpdatingBackgroundImage = false // Reset the flag
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadBackgroundPhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

}
