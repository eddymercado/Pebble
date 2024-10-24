//
//  EventCell.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/23/24.
//


import UIKit

class EventCell: UICollectionViewCell {
    
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
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Add and configure subviews programmatically
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        numPeopleLabel.translatesAutoresizingMaskIntoConstraints = false
        activitiesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(endTimeLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(numPeopleLabel)
        contentView.addSubview(activitiesLabel)
        
        // Layout constraints for your labels (adjust as needed)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            // Add other constraints here for positioning and sizing
        ])
    }
}

