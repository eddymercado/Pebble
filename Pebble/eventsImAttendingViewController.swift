//
//  eventsImAttendingViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 11/24/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

class eventsImAttendingViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventUsernameLabel: UILabel!
    @IBOutlet weak var profilePicMini: UIImageView!
    
    var eventsNeedToBePopluated: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
//        nextButton.setImage(UIImage(named: "rightarrow"), for: .normal)
//        nextButton.imageView?.contentMode = .scaleAspectFit
//        let config = UIImage.SymbolConfiguration(pointSize: nextButton.frame.height / 2, weight: .regular)
//        let image = UIImage(systemName: "rightarrow", withConfiguration: config)
//        nextButton.setImage(image, for: .normal)
        // Do any additional setup after loading the view.

        // populate for inital view

        print("here2")
        print(self.eventsNeedToBePopluated)
        db.collection("events").document(self.eventsNeedToBePopluated[0]).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
                    print(self.eventsNeedToBePopluated)
            if let document = document, document.exists {
                
                if let base64String = document.get("eventPic") as? String {
                    // Convert the Base64 string to UIImage
                    
                    if let image = self.decodeBase64ToImage(base64String) {
                        self.imageView.image = image // Set the decoded image in an UIImageView
                        self.imageView.contentMode = .scaleAspectFill
                    }
                }
                
                if let eventTitle = document.get("title") as? String {
                    self.eventTitleLabel.text = eventTitle
                }
                if let eventDate = document.get("date") as? String {
                    self.eventDateLabel.text = eventDate
                }
                if let eventUsername = document.get("hostUsername") as? String {
                    self.eventUsernameLabel.text = eventUsername
                }
                
            } else {
                print("Document does not exist")
            }
            
        }
        
    }
    
    func setUp(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument(source: .default) { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                self.eventsNeedToBePopluated = document.get("eventsThatUserIsAttending") as? [String] ?? []
                print("here4")
                print(self.eventsNeedToBePopluated)
            }
        }
        
        db.collection("events").document(self.eventsNeedToBePopluated[0]).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            print("here9")
            print(self.eventsNeedToBePopluated)
        }
    }
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    

}
