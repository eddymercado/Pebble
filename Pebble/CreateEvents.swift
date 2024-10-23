//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit

protocol EventCreationDelegate: AnyObject {
    func createdEvent(_ event: Event)
}

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
    
    weak var delegate:EventCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    
    @IBAction func createEventBtnPressed(_ sender: UIButton) {
        // Get selected date and times from date picker
        let selectedDate = eventDate.date
        let selectedStart = eventStartTime.date
        let selectedEnd = eventEndTime.date

        // Create a new instance of Event, populating inputs
        let newEvent = Event(
            title: eventTitle.text ?? "",
            description: eventDesc.text ?? "",
            date: selectedDate,
            startTime: selectedStart,
            endTime: selectedEnd,
            location: eventLocation.text ?? "",
            activities: eventActivityType.text ?? "",
            numPeople: Int(eventNumPeople.text ?? "0") ?? 0
        )

        // Notify delegate that a new event was created
        delegate?.createdEvent(newEvent)

        // Dismiss the view controller
        navigationController?.popViewController(animated: true)
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
    
    init(title: String, description: String, date: Date, startTime: Date, endTime: Date, location: String, activities: String, numPeople: Int) {
        self.title = title
        self.description = description
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.activities = activities
        self.numPeople = numPeople
    }
    
//    func addActivity(_ activity: String) {
//        //Check if activity exists in global list before adding to event
//        
//    }
}

// Singleton class, global list of activities
// Each event has its own associated list of activities
// which pulls from the class
class allActivities {
    //single instance
    static let shared = allActivities()
    
    //other classes cannot directly access this
    private(set) var globalActivities: [String] = ["Hiking", "Running"]
    
    //initializer
    private init() {}
    
    func addGlobalActivity(_ activity: String) {
        if !globalActivities.contains(activity) {
            globalActivities.append(activity)
            print("\(activity) has been added to the global list")
        } else {
            print("\(activity) already exists in the global list")
        }
    }
    
    func removeGlobalActivity(_ activity: String) {
        if let index = globalActivities.firstIndex(of: activity) {
            globalActivities.remove(at: index)
            print("\(activity) has been removed from the global activity list")
        } else {
            print("\(activity) does not exist in global activity list")
        }
    }
    //print all activities in global list
    func printActivities() {
        let activitiesList = globalActivities.joined(separator: ", ")
            print("Global activities: \(activitiesList)")
    }
}
