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

    func configure(with event: Event) {
        // Set the images
        eventImageView.image = UIImage(named: "eventImage")
        profileImageView.image = UIImage(named: "profileImage")

        // Set profile image to be circular
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true

        // Set event image to fill the view
        eventImageView.contentMode = .scaleAspectFill
        eventImageView.layer.cornerRadius = 12
        eventImageView.clipsToBounds = true

        // Set other event details
        profileUsernameLabel.text = "speddy"
        eventTitleLabel.text = event.title
        eventDateLabel.text = DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .none)
    }

}

