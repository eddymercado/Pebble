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
        // Load from UserDefaults or Firestore
        if let imageData = UserDefaults.standard.data(forKey: "profilePic"),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
        usernameTextField.text = UserDefaults.standard.string(forKey: "username")
        bioTextField.text = UserDefaults.standard.string(forKey: "bio")
    }
    
    @IBAction func uploadPhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @IBAction func saveProfileChanges(_ sender: UIButton) {
        // Save to UserDefaults or Firestore
        if let imageData = profileImageView.image?.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profilePic")
        }
        
        if let username = usernameTextField.text, !username.isEmpty {
            UserDefaults.standard.set(username, forKey: "username")
        }
        
        if let bio = bioTextField.text, !bio.isEmpty {
            UserDefaults.standard.set(bio, forKey: "bio")
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
