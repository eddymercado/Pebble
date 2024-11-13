//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

protocol EventCreationDelegate: AnyObject {
    func createdEvent(_ event: Event)
}

class CreateEvents: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDesc: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventEndTime: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventActivityType: UITextField!
    @IBOutlet weak var eventNumPeople: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
    weak var delegate:EventCreationDelegate?
    
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
                "hostId": userId
            ]

            // Add event to "events" collection
            db.collection("events").addDocument(data: eventData) { error in
                if let error = error {
                    print("error")
                } else {
                    if let image = self.eventImageView.image,
                       let imageData = image.jpegData(compressionQuality: 0.5) {
                        let base64String = imageData.base64EncodedString()
                        eventPic = base64String
                        Analytics.setUserProperty(base64String, forName: "Event Pic")
                    }
                    // Optional: Track analytics properties for the event
                    Analytics.setUserProperty(hostUsername, forName: "Host Username")
                    Analytics.setUserProperty(self.eventTitle.text ?? "", forName: "Event Title")
                    Analytics.setUserProperty(self.eventLocation.text ?? "", forName: "Event Location")
                    
                    // Notify the delegate and dismiss the view
                    let newEvent = Event(
                        title: eventData["title"] as! String,
                        description: eventData["description"] as! String,
                        date: eventData["date"] as! Date,
                        startTime: eventData["startTime"] as! Date,
                        endTime: eventData["endTime"] as! Date,
                        location: eventData["location"] as! String,
                        activities: eventData["activities"] as! String,
                        numPeople: eventData["numPeople"] as! Int,
                        hostUsername: hostUsername,
                        hostPfp: hostPfp,
                        eventPic: eventPic
                    )
                    self.delegate?.createdEvent(newEvent)
                    self.dismiss(animated: true)
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

class Event {
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var location: String
    //each event can be sorted by specific activities, ex. fitness and soccer
    var activities: String
    var numPeople: Int
    var hostUsername: String
    var hostPfp: String
    var eventPic: String
    //need RSVP list
    
    init(title: String, description: String, date: Date, startTime: Date, endTime: Date, location: String, activities: String, numPeople: Int, hostUsername: String, hostPfp: String, eventPic: String) {
        self.title = title
        self.description = description
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.activities = activities
        self.numPeople = numPeople
        self.hostUsername = hostUsername
        self.hostPfp = hostPfp
        self.eventPic = eventPic
    }
    
//    func addActivity(_ activity: String) {
//        //Check if activity exists in global list before adding to event
//
//    }
}

// Singleton class, global list of activities
// Each event has its own associated list of activities
// which pulls from the class
//class allActivities {
//    //single instance
//    static let shared = allActivities()
//
//    //other classes cannot directly access this
//    private(set) var globalActivities: [String] = ["Hiking", "Running"]
//
//    //initializer
//    private init() {}
//
//    func addGlobalActivity(_ activity: String) {
//        if !globalActivities.contains(activity) {
//            globalActivities.append(activity)
//            print("\(activity) has been added to the global list")
//        } else {
//            print("\(activity) already exists in the global list")
//        }
//    }
//
//    func removeGlobalActivity(_ activity: String) {
//        if let index = globalActivities.firstIndex(of: activity) {
//            globalActivities.remove(at: index)
//            print("\(activity) has been removed from the global activity list")
//        } else {
//            print("\(activity) does not exist in global activity list")
//        }
//    }
//    //print all activities in global list
//    func printActivities() {
//        let activitiesList = globalActivities.joined(separator: ", ")
//            print("Global activities: \(activitiesList)")
//    }
//}
