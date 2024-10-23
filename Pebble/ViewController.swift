//
//  ViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/14/24.
//

import UIKit

var eventsList: [Event] = []

class ViewController: UIViewController, EventCreationDelegate {
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"
    
    let createEventsSegueIdentifier = "createEventsSegueIdentifier"

    @IBOutlet weak var eventDetailsCreated: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func createdEvent(_event: Event) {
        //add new event to event list
        eventsList.append(_event)
        
        //access global activities and append to this event's activities, CHANGE LATER
        if let firstActivity = allActivities.shared.globalActivities.first {
            _event.activities.append(firstActivity)
        }
        
        let eventDetails = """
            Title: \(_event.title)
            Description: \(_event.description)
            Date: \(_event.date)
            Start Time: \(_event.startTime)
            End Time: \(_event.endTime)
            Location: \(_event.location)
            Number of People: \(_event.numPeople)
            Activities: \(_event.activities.joined(separator: ","))
            """
        
        eventDetailsCreated.text = eventDetails
    }
    
    // Sends info/Segues to ProfilePage View Controller and Create Events
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profilePageSegueIdentifier {
            if let nextVC = segue.destination as? ProfilePage {
                nextVC.delegate = self
            }
        } else if segue.identifier == createEventsSegueIdentifier {
            if let createVC = segue.destination as?
                CreateEvents {
                createVC.delegate = self
            }
        }
    }

}

