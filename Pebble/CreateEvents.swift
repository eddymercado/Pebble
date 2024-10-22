//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit

protocol EventCreationDelegate: AnyObject {
    func createdEvent(_event: Event)
}

class CreateEvents: UIViewController {
    
    
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDesc: UITextView!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventEndTime: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventActivityType: UITextField!
    @IBOutlet weak var eventNumPeople: UITextField!
    
    weak var delegate:EventCreationDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    
    @IBAction func createEventBtnPressed(_ sender: UIButton) {
        
        //get selected date and times from date picker
        let selectedDate = eventDate.date
        let selectedStart = eventStartTime.date
        let selectedEnd = eventEndTime.date
        
        //new instance of event, populate inputs
        let newEvent = Event (title: eventTitle.text ?? "", description: eventDesc.text ?? "", date: selectedDate, startTime: selectedStart, endTime: selectedEnd, location: eventLocation.text ?? "", numPeople: Int(eventNumPeople.text ?? "0") ?? 0
        )
        
        //notify delegate new event created
        delegate?.createdEvent(_event: newEvent)
        
        //need to add some navigation controller code to go to a diff VC potentially
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
    var activities: [String]
    var numPeople: Int
    
    init(title: String, description: String, date: Date, startTime: Date, endTime: Date, location: String, numPeople: Int) {
        self.title = title
        self.description = description
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.activities = []
        self.numPeople = numPeople
    }
    
    func addActivity(_ activity: String) {
        //Check if activity exists in global list before adding to event
        
    }
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
}
