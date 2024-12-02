//
//  EventCell.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/23/24.
//


import UIKit
import FirebaseFirestore

class EventCell: UICollectionViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }

    func configure(currEventID: String) {
        // Fetch event data from Firestore
        db.collection("events").document(currEventID).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                // Set event details
                if let username = document.get("hostUsername") as? String {
                    self.profileUsernameLabel.text = username
                }
                if let eventTitle = document.get("title") as? String {
                    self.eventTitleLabel.text = eventTitle
                }
                if let timestamp = document.get("date") as? Timestamp {
                    let eventDate = timestamp.dateValue()
                    self.eventDateLabel.text = DateFormatter.localizedString(from: eventDate, dateStyle: .medium, timeStyle: .none)
                }
                
                // Set images
                if let image = document.get("eventPic") as? String {
                    if let eventPic = self.decodeBase64ToImage(image) {
                        self.eventImageView.image = eventPic
                    }
                }
                
                if let image = document.get("hostPfp") as? String {
                    if let profilePic = self.decodeBase64ToImage(image) {
                        self.profileImageView.image = profilePic
                    }
                }
            }
        }
        
        // Set profile image styling
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Set event image styling
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.layer.cornerRadius = 12
        eventImageView.clipsToBounds = true

        // Add gradient overlay for readability
        addGradientOverlay(to: eventImageView)
        
        profileUsernameLabel.textColor = UIColor.white
        eventTitleLabel.textColor = UIColor.white
        eventDateLabel.textColor = UIColor.white
        
    }

    // Adds a gradient overlay to the bottom of eventImageView
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
}
