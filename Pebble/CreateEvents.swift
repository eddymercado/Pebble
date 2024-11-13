//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

//protocol EventCreationDelegate: AnyObject {
//    func createdEvent(_ event: Event)
//}

class CreateEvents: UIViewController {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDesc: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventEndTime: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventActivityType: UITextField!
    @IBOutlet weak var eventNumPeople: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
//    weak var delegate:EventCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    
    @IBAction func createEventBtnPressed(_ sender: UIButton) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }

            var hostUsername = "temp"
            var hostPfp = "temp"
            var eventPic = "temp"
            var currEventID = "temp"
            
            if let document = document, document.exists {
                hostPfp = document.get("profilePic") as? String ?? "temp"
                hostUsername = document.get("username") as? String ?? "temp"
            } else {
                print("Document does not exist")
            }
            
            // Prepare event data for Firestore
            let eventData: [String: Any] = [
                "title": self.eventTitle.text ?? "",
                "description": self.eventDesc.text ?? "",
                "date": self.eventDate.date,
                "startTime": self.eventStartTime.date,
                "endTime": self.eventEndTime.date,
                "location": self.eventLocation.text ?? "",
                "activities": self.eventActivityType.text ?? "",
                "numPeople": Int(self.eventNumPeople.text ?? "0") ?? 0,
                "hostUsername": hostUsername,
                "hostPfp": hostPfp,
                "hostId": userId,
                "eventPic": "",
                "eventID": ""
            ]

            // Step 1: Create a document reference with a unique ID
            let documentReference = db.collection("events").document()

            // Step 2: Set the data with the document reference
            documentReference.setData(eventData) { error in
                if error != nil {
                    print("error")
                } else {
                    currEventID = documentReference.documentID

                    if let image = self.eventImageView.image,
                       let imageData = image.jpegData(compressionQuality: 0.5) {
                        let base64String = imageData.base64EncodedString()
                        eventPic = base64String
                        db.collection("events").document(currEventID).updateData(["eventPic": eventPic])

                    }
                    
                    db.collection("events").document(currEventID).updateData(["eventID": currEventID])
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)

                    if let segueVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                        segueVC.createdEvent(currEventID)
                        segueVC.modalPresentationStyle = .fullScreen
                        self.present(segueVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}

extension CreateEvents:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let eventPic = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            eventImageView.image = eventPic
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

//class Event {
//    var title: String
//    var description: String
//    var date: Date
//    var startTime: Date
//    var endTime: Date
//    var location: String
//    //each event can be sorted by specific activities, ex. fitness and soccer
//    var activities: String
//    var numPeople: Int
//    var hostUsername: String
//    var hostPfp: String
//    var eventPic: String
//    var eventID: String
//    //need RSVP list
//    
//    init(title: String, description: String, date: Date, startTime: Date, endTime: Date, location: String, activities: String, numPeople: Int, hostUsername: String, hostPfp: String, eventPic: String, eventID: String) {
//        self.title = title
//        self.description = description
//        self.date = date
//        self.startTime = startTime
//        self.endTime = endTime
//        self.location = location
//        self.activities = activities
//        self.numPeople = numPeople
//        self.hostUsername = hostUsername
//        self.hostPfp = hostPfp
//        self.eventPic = eventPic
//        self.eventID = eventID
//    }
//
//}

