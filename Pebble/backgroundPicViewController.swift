//
//  backgroundPicViewController.swift
//  Pebble
//
//  Created by Tesna Thomas on 11/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class backgroundPicViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let db = Firestore.firestore()

    @IBOutlet weak var backgroundImageView: UIImageView!
    var isPhotoUploaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Upload photo button action
    @IBAction func uploadBackgroundPhotoButtonTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // Save background picture to Firestore
    @IBAction func backgroundPicSaveButtonTapped(_ sender: Any) {
        guard let backgroundImage = backgroundImageView.image,
              let imageData = backgroundImage.jpegData(compressionQuality: 0.5) else {
            showAlert(title: "Error", message: "No background image selected!")
            return
        }
        
        let base64String = imageData.base64EncodedString()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).updateData(["backgroundPic": base64String]) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save background picture: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Background picture successfully saved!")
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
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            let targetSize = CGSize(width: 393, height: 169)
            backgroundImageView.image = cropToTargetSize(image: selectedImage, size: targetSize)
            isPhotoUploaded = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropToTargetSize(image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }

}
