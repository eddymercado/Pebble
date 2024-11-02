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

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var eventSegmentView: UIView!
    @IBOutlet weak var myEventSegmentView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProfilePic()
        
        // Retrieve the username from UserDefaults
        if let usernameData = UserDefaults.standard.string(forKey: "username") {
            usernameLabel.text = usernameData
        }
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
//        let event = events[indexPath.row]
//        // Set the event image
//        if let imageName = event["image"] {
//            cell.eventImageView.image = UIImage(named: cultural_gathering_image)
//        }
        return cell
    }
    
//    @IBAction func settingsButtonPressed(_ sender: Any) {
//        print("MADE IT!!!!!")
//        //        let controller = UIAlertController(
////            title: "",
////            message: "",
////            preferredStyle: .actionSheet)
////        
////        // meat options
////        controller.addAction(UIAlertAction(title: "Update Profile", style: .default) {_ in
////            // Code to update profile goes here
////            print("Update Profile selected")})
////        controller.addAction(UIAlertAction(title: "Update Interests", style: .default) {_ in
////            // Code to update interests goes here
////            print("Update Interests selected")})
////        controller.addAction(UIAlertAction(title: "Update Info", style: .default) {_ in // Code to update info goes here
////            print("Update Info selected")})
////        self.present(controller, animated: true, completion: nil)
//    }

}
