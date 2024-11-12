//
//  ViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/14/24.
//

import UIKit

// Ensure eventsList is properly initialized
var eventsList: [Event] = []

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EventCreationDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"
    let createEventsSegueIdentifier = "createEventsSegueIdentifier"
    let openSingleEventSegue = "showSingleEvent"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register the EventCell class (no NIB needed)
//        collectionView.register(EventCell.self, forCellWithReuseIdentifier: "EventCell")
        
        // Configure layout for the collection view
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: view.frame.width - 20, height: 200) // Adjust height as needed
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
//        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.lightGray // For debugging
    }

    
    // MARK: - EventCreationDelegate
    func createdEvent(_ event: Event) {
        // Add the new event to the events list
        eventsList.append(event)
        
        // Reload collection view to show the new event
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsList.count // Number of events determines the number of items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        
        let event = eventsList[indexPath.item]
        cell.configure(with: event)
        
        // Add a tap gesture recognizer to the cell
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
            cell.addGestureRecognizer(tapGesture)

        return cell
    }
    
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            print("Cell tapped at index: \(indexPath.item)")
            let selectedEvent = eventsList[indexPath.item]
            performSegue(withIdentifier: openSingleEventSegue, sender: selectedEvent)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell selected at index: \(indexPath.item)")
        let selectedEvent = eventsList[indexPath.item]
        print("Selected event: \(selectedEvent)")
        performSegue(withIdentifier: openSingleEventSegue, sender: selectedEvent)
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare(for:sender:) called in ViewController")
        print("Segue identifier: \(segue.identifier ?? "nil")")
        print("Destination view controller: \(segue.destination)")
        print("Sender: \(String(describing: sender))")
        if segue.identifier == profilePageSegueIdentifier {
            if let nextVC = segue.destination as? ProfilePage {
                nextVC.delegate = self // Set the delegate for ProfilePage
            }
        } else if segue.identifier == createEventsSegueIdentifier {
            if let createVC = segue.destination as? CreateEvents {
                createVC.delegate = self // Set the delegate for CreateEvents
            }
        } else if segue.identifier == openSingleEventSegue {
            print("Segue to SingleEventViewController")
            if let singleEventVC = segue.destination as? SingleEventViewController, let selectedEvent = sender as? Event {
                print("Event being passed: \(selectedEvent)")
                singleEventVC.event = selectedEvent
            } else {
                print("Failed to cast destination to SingleEventViewController or sender to Event")
            }
        } else {
            print("Unknown segue identifier: \(segue.identifier ?? "nil")")
        }
    }
}
