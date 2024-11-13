//
//  EventCell.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/23/24.
//


import UIKit

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
        
        db.collection("events").document(currEventID).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                // Set other event details
                
                if let username = document.get("hostUsername") as? String {
                    self.profileUsernameLabel.text = username
                }
                if let eventTitle = document.get("title") as? String {
                    self.eventTitleLabel.text = eventTitle
                }
                if let eventDate = document.get("date") as? Date {
                    self.eventDateLabel.text = DateFormatter.localizedString(from: eventDate, dateStyle: .medium, timeStyle: .none)
                }
                
                // Set the images
                if let image = document.get("eventPic") as? String {
                    if let eventPic = self.decodeBase64ToImage(image) {
                        self.eventImageView.image = eventPic
                    }
                } /* else {
                    self.eventImageView.image = UIImage(named: "eventImage") // is this default ?
                } */
                
                if let image = document.get("hostPfp") as? String {
                    if let profilePic = self.decodeBase64ToImage(image) {
                        self.profileImageView.image = profilePic
                    }
                } /* else {
                    self.profileImageView.image = UIImage(named: "profileImage")
                } */
            }
        }
        // Set profile image to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Set event image to fill the view
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.layer.cornerRadius = 12
        eventImageView.clipsToBounds = true


    }

}

