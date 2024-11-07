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
    
    func setupUI() {
        view.backgroundColor = .systemGray6
    }

    func setupProfilePic() {
        profilePic.frame.size.width = profilePic.frame.size.height
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        view.addSubview(profilePic)
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
        // Clear any existing rows in the stack view
        interestsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Start a new row
        var currentRowStackView = createHorizontalStackView()

        for interest in selectedInterests {
            let label = UILabel()
            label.text = " \(interest) "
            label.textAlignment = .center
            label.backgroundColor = UIColor.systemBlue
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
            label.sizeToFit()

            // Add constraints to ensure proper sizing
            label.translatesAutoresizingMaskIntoConstraints = false
            label.heightAnchor.constraint(equalToConstant: 30).isActive = true

            // Calculate the total width of the current row + the new label
            let totalWidth = currentRowStackView.arrangedSubviews.reduce(0) { $0 + $1.frame.width }
                            + label.intrinsicContentSize.width
                            + (CGFloat(currentRowStackView.arrangedSubviews.count) * currentRowStackView.spacing)

            if totalWidth > interestsStackView.frame.width {
                // If adding this label exceeds the row width, finalize the current row and start a new one
                interestsStackView.addArrangedSubview(currentRowStackView)
                currentRowStackView = createHorizontalStackView()
            }

            // Add the label to the current row
            currentRowStackView.addArrangedSubview(label)
        }

        // Add the final row if it has any labels
        if !currentRowStackView.arrangedSubviews.isEmpty {
            interestsStackView.addArrangedSubview(currentRowStackView)
        }
    }

    // Helper function to create a horizontal stack view
    private func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8 // Adjust spacing as necessary
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
        print("hi here")
        print(selectedInterests)
    }

}
