//
//  ProfilePage.swift
//  Pebble
//
//  Created by Tesna Thomas on 10/17/24.
//

import UIKit

class ProfilePage: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate: ViewController!
    let eventCellIdentifier = "EventCell"

    // Sample data for events
    var events = [
//        ["date": "Oct 26", "name": "Halloween Party", "host": "John Doe", "location": "1234 Point North Avenue, Austin, TX"],
        ["image": "cultural_gathering_image"]
        // Add more events here
    ]
    
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProfilePic()
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: eventCellIdentifier, for: indexPath)
//        let event = events[indexPath.row]
//        // Set the event image
//        if let imageName = event["image"] {
//            cell.eventImageView.image = UIImage(named: cultural_gathering_image)
//        }
        return cell
    }

}
