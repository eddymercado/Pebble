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

    func configure(with event: Event) {
        // Set the images
        if let image = decodeBase64ToImage(event.eventPic) {
            eventImageView.image = image // Set the decoded image in an UIImageView
        } else {
            eventImageView.image = UIImage(named: "eventImage")
        }
        if let image = decodeBase64ToImage(event.hostPfp) {
            profileImageView.image = image // Set the decoded image in an UIImageView
        } else {
            profileImageView.image = UIImage(named: "profileImage")
        }

        // Set profile image to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Set event image to fill the view
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.layer.cornerRadius = 12
        eventImageView.clipsToBounds = true

        // Set other event details
        profileUsernameLabel.text = event.hostUsername
        eventTitleLabel.text = event.title
        eventDateLabel.text = DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .none)
    }

}

