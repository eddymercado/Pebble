//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

class selectInterestsViewController: UIViewController {
    var count = 0;
    var arrayOfInterests: [String] = []
    let db = Firestore.firestore()

    // let activities = allActivities.shared.globalActivities


    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func genericPush(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal) ?? "NaN"
            
            if sender.isSelected {
                // If the button is already selected, deselect it
                sender.isSelected = false
                sender.backgroundColor = UIColor.systemGray2
                // Remove the last added interest since this button is being deselected
                if let index = arrayOfInterests.firstIndex(of: buttonTitle) {
                    arrayOfInterests.remove(at: index)
                    count -= 1
                }
            } else {
                // If the button is not selected, check if we can select it
                if count < 5 {
                    sender.isSelected = true
                    sender.backgroundColor = UIColor.systemBlue
                    arrayOfInterests.append(buttonTitle)
                    count += 1
                } else {
                    // If the limit is reached, show an alert
                    showAlert(title: "Only 5 interests can be selected", message: "")
                }
            }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        // add array of interests to user profile in firstore
        
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userData: [String: Any] = ["Interests": arrayOfInterests]
        
        self.db.collection("users").document(userId).updateData(userData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "\(error.localizedDescription)")
            } else {
                let interestsString = self.arrayOfInterests.joined(separator: ", ")
                Analytics.setUserProperty(interestsString, forName: "Interests")
            }
            self.performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
            
        }
    }

    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
