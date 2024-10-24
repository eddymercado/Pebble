//
//  ViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/14/24.
//

import UIKit

var eventsList: [Event] = []

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EventCreationDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"
    let createEventsSegueIdentifier = "createEventsSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")

        
        // Configure layout for the collection view
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 200) // Adjust height as needed
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.lightGray // For debugging

        print("Collection view frame: \(collectionView.frame)")
    }

    
    // MARK: - EventCreationDelegate
    func createdEvent(_ event: Event) {
        eventsList.append(event)
        DispatchQueue.main.async {
            print("Reloading collection view with \(eventsList.count) events")
            self.collectionView.reloadData()
       }
        print("Event created: \(event.title)")
        print("Description: \(event.description)")
        print("Date: \(event.date)")
        print("Start Time: \(event.startTime)")
        print("End Time: \(event.endTime)")
        print("Location: \(event.location)")
        print("Number of People: \(event.numPeople)")
        print("Activity: \(event.activities)")
        print("Total events: \(eventsList.count)")
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("I have \(eventsList.count) events")
        return eventsList.count // Number of events determines the number of items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt called for index: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        let event = eventsList[indexPath.item]
        
        // Configure the cell with event details
        cell.titleLabel.text = "Title: \(event.title)"
        cell.descriptionLabel.text = "Descirption: \(event.description)"
        cell.dateLabel.text = "Date: \(DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .none))"
        cell.startTimeLabel.text = "Start Time: \(DateFormatter.localizedString(from: event.startTime, dateStyle: .none, timeStyle: .short))"
        cell.endTimeLabel.text = "End Time: \(DateFormatter.localizedString(from: event.endTime, dateStyle: .none, timeStyle: .short))"
        cell.locationLabel.text = "Location: \(event.location)"
        cell.numPeopleLabel.text = "Headcount: \(event.numPeople)"
        cell.activitiesLabel.text = "Activity: \(event.activities)"
        
        return cell
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profilePageSegueIdentifier {
            if let nextVC = segue.destination as? ProfilePage {
                nextVC.delegate = self // Set the delegate for ProfilePage
            }
        } else if segue.identifier == createEventsSegueIdentifier {
            if let createVC = segue.destination as? CreateEvents {
                createVC.delegate = self // Set the delegate for CreateEvents
            }
        }
    }
}
