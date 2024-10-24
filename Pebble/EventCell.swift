//
//  EventCell.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/23/24.
//


import UIKit

class EventCell: UICollectionViewCell {
    
    // Define the labels
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let dateLabel = UILabel()
    let startTimeLabel = UILabel()
    let endTimeLabel = UILabel()
    let locationLabel = UILabel()
    let numPeopleLabel = UILabel()
    let activitiesLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure and add the labels
        configureLabel(titleLabel)
        configureLabel(descriptionLabel)
        configureLabel(dateLabel)
        configureLabel(startTimeLabel)
        configureLabel(endTimeLabel)
        configureLabel(locationLabel)
        configureLabel(numPeopleLabel)
        configureLabel(activitiesLabel)
        
        // Set up Auto Layout constraints
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Helper method to configure a label
    private func configureLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0 // Allow for multiline text
        contentView.addSubview(label)
    }
    
    // Set up constraints for each label
    private func setupConstraints() {
        // Constraints for titleLabel (anchored to top)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for descriptionLabel (below titleLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for dateLabel (below descriptionLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for startTimeLabel
        NSLayoutConstraint.activate([
            startTimeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            startTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            startTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for endTimeLabel
        NSLayoutConstraint.activate([
            endTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 5),
            endTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            endTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for locationLabel
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for numPeopleLabel
        NSLayoutConstraint.activate([
            numPeopleLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            numPeopleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            numPeopleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        // Constraints for activitiesLabel
        NSLayoutConstraint.activate([
            activitiesLabel.topAnchor.constraint(equalTo: numPeopleLabel.bottomAnchor, constant: 5),
            activitiesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            activitiesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            activitiesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10) // Anchor to the bottom
        ])
    }
}
