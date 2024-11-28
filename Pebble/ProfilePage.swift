//
//  ProfilePage.swift
//  Pebble
//
//  Created by Tesna Thomas on 10/17/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal
import FirebaseCore

class ProfilePage: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var delegate: ViewController!
    let eventCellIdentifier = "EventCell"
    var selectedInterests: [String] = []
    let db = Firestore.firestore()

    // Sample data for events
    var eventsToBeDisplayed: [String] = []
    var events = [
        ["image": "cultural_gathering_image"]
    ]
    @IBOutlet weak var noEventsToDisplayLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var interestsStackView: UIStackView!
    @IBOutlet weak var backupInterestsStackView: UIStackView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var eventSegmentLabel: UISegmentedControl!
    @IBOutlet weak var eventUsernameLabel: UILabel!
    @IBOutlet weak var profilePicMini: UIImageView!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundPic: UIImageView!
    
    
    var hosting: [String] = []
    var attending: [String] = []
    var currEventToDisplay = 0
    var attedningorhosting = ""
    var selectedEvent = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        currEventToDisplay = 0
        if let image = UIImage(named: "rightarrow") {
            let scaledImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
                image.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            nextButton.setImage(scaledImage, for: .normal)
        }
        if let image = UIImage(named: "leftarrow") {
            let scaledImage = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
                image.draw(in: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            }
            backButton.setImage(scaledImage, for: .normal)
        }
        
        // add button
        let hiddenButton = UIButton(type: .system)
        hiddenButton.frame = imageView.frame
        hiddenButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.insertSubview(hiddenButton, belowSubview: imageView)
        
        attedningorhosting = "eventsThatUserIsAttending"
        setUp()
        fetchInterestsFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventSegmentLabel.selectedSegmentIndex = 0
        attedningorhosting = "eventsThatUserIsAttending"
        currEventToDisplay = 0
        setUp()
        setupProfileInfo() // Ensure profile data is updated
        fetchInterestsFromFirestore()
    }
    
    func setUp() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument(source: .default) { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }


            if let document = document, document.exists {
                if(self.attedningorhosting == "eventsThatUserIsAttending") {
                    self.attending = document.get("eventsThatUserIsAttending") as? [String] ?? []
                } else {
                    self.attending = document.get("eventsThatUserIsHosting") as? [String] ?? []
                }
                if(self.attending.isEmpty) {
                    self.eventTitleLabel.isHidden = true
                    self.eventDateLabel.isHidden = true
                    self.eventUsernameLabel.isHidden = true
                    self.imageView.isHidden = true
                    self.profilePicMini.isHidden = true
                    self.noEventsToDisplayLabel.isHidden = false
                } else {
                    self.eventTitleLabel.isHidden = false
                    self.eventDateLabel.isHidden = false
                    self.eventUsernameLabel.isHidden = false
                    self.imageView.isHidden = false
                    self.profilePicMini.isHidden = false
                    self.noEventsToDisplayLabel.isHidden = true
                    self.db.collection("events").document(self.attending[self.currEventToDisplay]).getDocument { (document, error) in
                        if let error = error {
                            print("Error retrieving document: \(error.localizedDescription)")
                            return
                        }
                        if let document = document, document.exists {
                            self.selectedEvent = document.get("eventID") as? String ?? ""
                            if let base64String = document.get("eventPic") as? String {
                                // Convert the Base64 string to UIImage
                                
                                if let image = self.decodeBase64ToImage(base64String) {
                                    self.imageView.image = image
                                    self.imageView.contentMode = .scaleAspectFill
                                }
                            }
                            
                            if let eventTitle = document.get("title") as? String {
                                self.eventTitleLabel.text = eventTitle
                            }
                            if let timestamp = document.get("date") as? Timestamp {
                                let eventDate = timestamp.dateValue()
                                self.eventDateLabel.text = DateFormatter.localizedString(from: eventDate, dateStyle: .medium, timeStyle: .none)
                            }
                            if let eventUsername = document.get("hostUsername") as? String {
                                self.eventUsernameLabel.text = eventUsername
                            }
                            
                            if let image = document.get("hostPfp") as? String {
                                if let profilePic = self.decodeBase64ToImage(image) {
                                    self.profilePicMini.image = profilePic
                                }
                            }
                            // Set profile image styling
                            self.profilePicMini.layer.cornerRadius = self.profilePicMini.frame.height / 2
                            self.profilePicMini.clipsToBounds = true
                            self.profilePicMini.contentMode = .scaleAspectFill

                            // Set event image styling
                            self.imageView.contentMode = .scaleAspectFill
                            self.imageView.layer.cornerRadius = 12
                            self.imageView.clipsToBounds = true

                            // Add gradient overlay for readability
                            self.addGradientOverlay(to: self.imageView)
                            
                            self.eventUsernameLabel.textColor = UIColor.white
                            self.eventTitleLabel.textColor = UIColor.white
                            self.eventDateLabel.textColor = UIColor.white
                            
                            
                        }
                    }
                }
                
            }
        }
    }

    func addGradientOverlay(to imageView: UIImageView) {
        // Remove any existing gradient layers to prevent duplicates
        imageView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // Starts at the bottom
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)   // Fades up halfway
        gradientLayer.cornerRadius = imageView.layer.cornerRadius
        
        imageView.layer.addSublayer(gradientLayer)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = imageView.bounds
        gradientLayer2.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer2.locations = [0.0, 1.0]
        gradientLayer2.startPoint = CGPoint(x: 0.5, y: 0) // Starts at the top
        gradientLayer2.endPoint = CGPoint(x: 0.5, y: 0.5)   // Fades down halfway
        gradientLayer2.cornerRadius = imageView.layer.cornerRadius
        
        imageView.layer.addSublayer(gradientLayer2)
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
            
            // Load background picture
            if let backgroundBase64String = document?.get("backgroundPic") as? String,
               let backgroundImage = self.decodeBase64ToImage(backgroundBase64String) {
                self.backgroundPic.image = backgroundImage
                self.backgroundPic.contentMode = .scaleAspectFill
            }
            
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
                
                self.populateInterests()
                
            } else {
                print("Document does not exist")
            }
            
        }
    }
    
    @objc func buttonTapped() {
        presentSingleEventVC(selectedEvent: selectedEvent)
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        if(attending.count != currEventToDisplay + 1){
            currEventToDisplay = currEventToDisplay + 1
            setUp()
        }
        
    }
    @IBAction func backButtonPushed(_ sender: Any) {
        if(currEventToDisplay != 0){
            currEventToDisplay = currEventToDisplay - 1
            setUp()
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
//            print("Update Interests selected")
            // Perform actions for updating interests
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "selectInterestsViewController") as? selectInterestsViewController {
                updateProfileVC.modalPresentationStyle = .fullScreen
                updateProfileVC.cameFromUpdateInterests = true
                self.present(updateProfileVC, animated: true, completion: nil)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Update Info", style: .default, handler: { _ in
//            print("Update Info selected")
            // Perform actions for updating info
            // Navigate to UpdateProfileVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "updateInfoViewController") as? updateInfoViewController {
                updateProfileVC.modalPresentationStyle = .fullScreen
                self.present(updateProfileVC, animated: true, completion: nil)
            }

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Update Location", style: .default, handler: { _ in
            print("Update Location selected")
            // Perform actions for updating location
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { _ in
            do {
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let updateProfileVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                    updateProfileVC.modalPresentationStyle = .fullScreen
                    self.present(updateProfileVC, animated: true, completion: nil)
                }
            } catch {
                print("Sign out error")
            }
        }))

        
        // Add a cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }

    
    // Event Segment Changer
    @IBAction func eventSegment(_ sender: UISegmentedControl) {
  
        
        guard let userId = Auth.auth().currentUser?.uid else { return }

            
        switch sender.selectedSegmentIndex {
            case 0:
            currEventToDisplay = 0
            attedningorhosting = "eventsThatUserIsAttending"
            setUp()
            case 1:
            currEventToDisplay = 0
            attedningorhosting = "eventsThatUserIsHosting"
            setUp()
            default:
                break
        }
    }
    
    func putTheRightEventToBeDisplyed() {
        
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
            label.backgroundColor = UIColor(red: 195/255, green: 228/255, blue: 214/255, alpha: 1)
            label.textColor = UIColor(red: 42/255, green: 102/255, blue: 54/255, alpha: 1)
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
    
    func presentSingleEventVC(selectedEvent: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let segueVC = storyboard.instantiateViewController(withIdentifier: "SingleEventViewController") as? SingleEventViewController {
            segueVC.currEventID = selectedEvent
            segueVC.didIComeFromProfilePage = true
            currEventToDisplay = currEventToDisplay - 1
            self.present(segueVC, animated: true, completion: nil)
        }
    }
    
    // here
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        setUp()
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
