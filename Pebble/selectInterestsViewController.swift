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



class selectInterestsViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    var count = 0;
    var arrayOfInterests: [String] = []
    let db = Firestore.firestore()
    var cameFromUpdateInterests = false
    // let activities = allActivities.shared.globalActivities


    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // add view will appear to show already chosen interests
    override func viewWillAppear(_ animated: Bool) {

        // populate interests
        
        // set all buttons to grey
        for subview in view.subviews {
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 10
                button.layer.masksToBounds = true
            }
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user interests: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data(), let interests = data["Interests"] as? [String] {
                self.arrayOfInterests = interests
                self.count = interests.count
                for title in interests {
                    if let button = self.findButton(withTitle: title, in: self.view) {
//                        button.backgroundColor = UIColor(red: 195/255, green: 228/255, blue: 214/255, alpha: 1)
                        button.backgroundColor = UIColor.systemGreen
                        button.isSelected = true
                    } else {
                        print("Button with title \(title) not found")
                    }
                }
            }
        }
        
        if(self.cameFromUpdateInterests) {
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
            
            // Add the button to the view
            self.view.addSubview(backButton)
        }

    }
    
    func findButton(withTitle title: String, in view: UIView) -> UIButton? {
        for subview in view.subviews {
            if let button = subview as? UIButton, button.titleLabel?.text == title {
                return button
            } else if !subview.subviews.isEmpty {
                if let foundButton = findButton(withTitle: title, in: subview) {
                    return foundButton
                }
            }
        }
        return nil
    }
    
    @objc func backButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let segueVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController {
            segueVC.selectedIndex = 2
            segueVC.modalPresentationStyle = .fullScreen
            self.present(segueVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func genericPush(_ sender: UIButton) {
        let buttonTitle = sender.titleLabel?.text
        if sender.isSelected {
            // If the button is already selected, deselect it
            sender.isSelected = false
//            sender.backgroundColor = UIColor.white
            sender.backgroundColor = UIColor.secondarySystemBackground
            // Remove the last added interest since this button is being deselected
            if let index = arrayOfInterests.firstIndex(of: buttonTitle!) {
                arrayOfInterests.remove(at: index)
                count -= 1
            }
        } else {
            // If the button is not selected, check if we can select it
            if count < 5 {
                sender.isSelected = true
//                sender.backgroundColor = UIColor(red: 195/255, green: 228/255, blue: 214/255, alpha: 1)
                sender.backgroundColor = UIColor.systemGreen
                arrayOfInterests.append(buttonTitle!)
                count += 1
            } else {
                // If the limit is reached, show an alert
                showAlert(title: "Only 5 interests can be selected", message: "")
            }
        }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        // add array of interests to user profile in firstore
        if(count == 0) {
            showAlert(title: "Please select at least 1 interest.", message: "")
        } else {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user interests: \(error.localizedDescription)")
                    return
                }

                if let document = document, let data = document.data(), let interests = data["Interests"] as? [String] {
                    self.arrayOfInterests = interests
                }
            }
            
            let userData: [String: Any] = ["Interests": arrayOfInterests]

            self.db.collection("users").document(userId).updateData(userData) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: "\(error.localizedDescription)")
                } else {
                    let interestsString = self.arrayOfInterests.joined(separator: ", ")
                    Analytics.setUserProperty(interestsString, forName: "Interests")
                }
                
                // add if it came from porfile update go back to profile page if not still in sign up mode and need o degue to browse events
                if self.cameFromUpdateInterests {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let segueVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController {
                        segueVC.selectedIndex = 2 // Replace with the index of the desired child view controller
                        // 1 is create event
                        // 2 is profile page
                        // 3 is browse events
                        segueVC.modalPresentationStyle = .fullScreen
                        self.present(segueVC, animated: true, completion: nil)
                    }
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let segueVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController {
                        segueVC.modalPresentationStyle = .fullScreen
                        self.present(segueVC, animated: true, completion: nil)
                    }
                }
                
                
            }
        }
        
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
