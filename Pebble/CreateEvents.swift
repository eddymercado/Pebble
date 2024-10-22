//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit

class CreateEvents: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
