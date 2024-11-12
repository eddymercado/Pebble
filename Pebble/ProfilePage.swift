//
//  ProfilePage.swift
//  Pebble
//
//  Created by Tesna Thomas on 10/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class ProfilePage: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: ViewController!
    let eventCellIdentifier = "EventCell"
    var selectedInterests: [String] = []
    let db = Firestore.firestore()

    // Sample data for events
    var events = [
//        ["date": "Oct 26", "name": "Halloween Party", "host": "John Doe", "location": "1234 Point North Avenue, Austin, TX"],
        ["image": "cultural_gathering_image"]
        // Add more events here
    ]

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var eventSegmentView: UIView!
    @IBOutlet weak var myEventSegmentView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var interestsStackView: UIStackView!
    @IBOutlet weak var backupInterestsStackView: UIStackView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInterestsFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProfileInfo() // Ensure profile data is updated
    }
    
    func setupProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }

            // Ensure the image view is a square
            let width = self.profilePic.frame.size.width
            self.profilePic.layer.cornerRadius = width / 2
            self.profilePic.clipsToBounds = true
            
            // Maintain aspect fill for the image
            self.profilePic.contentMode = .scaleAspectFill
            
            if let document = document, document.exists {

                if let base64String = document.get("profilePic") as? String {
                    // Convert the Base64 string to UIImage

                    if let image = self.decodeBase64ToImage(base64String) {
                        self.profilePic.image = image // Set the decoded image in an UIImageView
                    }
                }
                
                if let username = document.get("username") as? String {
                    self.usernameLabel.text = username
                } else {
                    print("Username not found or not a string")
                }
                
                if let bio = document.get("bio") as? String {
                    self.bioLabel.text = bio
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
    
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Button tapped")
        // Create the action sheet
        let actionSheet = UIAlertController(title: "Settings", message: "Select an option to update", preferredStyle: .actionSheet)
        
        // Add actions for each setting option
        actionSheet.addAction(UIAlertAction(title: "Update Profile", style: .default, handler: { _ in
            print("Update Profile selected")
            // Navigate to UpdateProfileVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "UpdateProfileViewController") as? UpdateProfileViewController {
                updateProfileVC.modalPresentationStyle = .fullScreen
                self.present(updateProfileVC, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Update Interests", style: .default, handler: { _ in
            print("Update Interests selected")
            // Perform actions for updating interests
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Update Info", style: .default, handler: { _ in
            print("Update Info selected")
            // Perform actions for updating info
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Update Location", style: .default, handler: { _ in
            print("Update Location selected")
            // Perform actions for updating location
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { _ in
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true)
            } catch {
                print("Sign out error")
            }
        }))

        
        // Add a cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    func setupUI() {
        view.backgroundColor = .systemGray6
    }

    
    // Event Segment Changer
    @IBAction func eventSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
            self.view.bringSubviewToFront(eventSegmentView)
            case 1:
            self.view.bringSubviewToFront(myEventSegmentView)
            default:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: eventCellIdentifier, for: indexPath)
        return cell
    }
    
    func populateInterests() {
        // Clear any existing rows in both stack views
        interestsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        backupInterestsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Start a new row for the primary stack view
        var currentRowStackView = createHorizontalStackView()
        interestsStackView.addArrangedSubview(currentRowStackView)

        for interest in selectedInterests {
            let label = UILabel()
            label.text = " \(interest) "
            label.textAlignment = .center
            label.backgroundColor = UIColor.systemBlue
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            label.layer.cornerRadius = 6
            label.clipsToBounds = true

            // Ensure dynamic size for the label
            label.translatesAutoresizingMaskIntoConstraints = false
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true

            // Calculate label width
            let labelWidth = label.intrinsicContentSize.width + 16 // Adding internal padding

            // Calculate current row width including spacing
            let totalWidth = currentRowStackView.arrangedSubviews.reduce(0) { $0 + $1.intrinsicContentSize.width + 16 }
                             + CGFloat(currentRowStackView.arrangedSubviews.count) * currentRowStackView.spacing
                             + labelWidth

            // Check if current row exceeds the width of the interestsStackView
            if totalWidth > interestsStackView.frame.width {
                // If adding exceeds primary stack view width, check if it's in the backup stack view
                if currentRowStackView.superview === interestsStackView {
                    // Move to backup stack view
                    currentRowStackView = createHorizontalStackView()
                    backupInterestsStackView.addArrangedSubview(currentRowStackView)
                }
            }

            currentRowStackView.addArrangedSubview(label)
        }

        // Force layout updates
        interestsStackView.layoutIfNeeded()
        backupInterestsStackView.layoutIfNeeded()
    }

    // Helper function to create horizontal stack views
    private func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8 // Space between labels
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    func fetchInterestsFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user interests: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data(), let interests = data["Interests"] as? [String] {
                self.selectedInterests = interests
                self.populateInterests()
            }
        }
    }
}
