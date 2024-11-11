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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProfilePic()
        
        // Retrieve the username from UserDefaults
        if let usernameData = UserDefaults.standard.string(forKey: "username") {
            usernameLabel.text = usernameData
        }
        fetchInterestsFromFirestore()
    }
    
    
    @IBAction func settingsButtonClicked(_ sender: Any) {
        print("Button tapped")
        // Create the action sheet
        let actionSheet = UIAlertController(title: "Settings", message: "Select an option to update", preferredStyle: .actionSheet)
        
        // Add actions for each setting option
        actionSheet.addAction(UIAlertAction(title: "Update Profile", style: .default, handler: { _ in
            print("Update Profile selected")
            // Perform actions for updating profile
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
        
        // Add a cancel button
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    func setupUI() {
        view.backgroundColor = .systemGray6
    }

    func setupProfilePic() {
        // Ensure the image view is a square
        let width = profilePic.frame.size.width
        profilePic.layer.cornerRadius = width / 2
        profilePic.clipsToBounds = true
        
        // Maintain aspect fill for the image
        profilePic.contentMode = .scaleAspectFill

        // Retrieve and set the image
        if let imageData = UserDefaults.standard.data(forKey: "profilePic"),
           let image = UIImage(data: imageData) {
            profilePic.image = image
        } else {
            profilePic.image = UIImage(systemName: "person.circle") // Default placeholder
        }
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
