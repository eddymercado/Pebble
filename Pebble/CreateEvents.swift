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
    var activity: String
    var numPeople: Int
    
    init(title: String, description: String, date: Date, startTime: Date, endTime: Date, location: String, activity: String, numPeople: Int) {
        self.title = title
        self.description = description
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.activity = activity
        self.numPeople = numPeople
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
}
