//
//  profilePicViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseStorage

class profilePicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()

    @IBOutlet weak var imageView: UIImageView!
    var isPhotoUploaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func uploadPhotoButton(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func profilePicSaveButton(_ sender: Any) {
        if let image = imageView.image,
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
    }
    
    // Show alert method to display errors or messages
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let profilePic = info[.editedImage] as? UIImage {
            imageView.image = profilePic
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
