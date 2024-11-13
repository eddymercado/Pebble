//
//  ViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/14/24.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

// Ensure eventsList is properly initialized
var eventsList: [String] = []

class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"
    let createEventsSegueIdentifier = "createEventsSegueIdentifier"
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.lightGray // For debugging
        fetchAllEvents()
    }
    

    func fetchAllEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                // Clear eventsList to avoid duplications
                eventsList.removeAll()
                
                // Loop through each document in the collection
                for document in querySnapshot!.documents {
                    // Assuming each document has a field "name" or "title" of type String
                    if let eventID = document.get("eventID") as? String {
                        // maybe sort by sometihng !!
                        eventsList.append(eventID) // Add event name to the array
                    }
                }
                // Print or use the array as needed
                print("All events: \(eventsList)")
                
                // Reload the collection view or table view if you need to display data
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func createdEvent(_ event: String) {
        eventsList.append(event)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsList.count // Number of events determines the number of items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        let event = cell.configure(currEventID: eventsList[indexPath.item])
        
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
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if let segueVC = storyboard.instantiateViewController(withIdentifier: "SingleEventViewController") as? SingleEventViewController {
                segueVC.currEventID = selectedEvent
                segueVC.modalPresentationStyle = .fullScreen
                self.present(segueVC, animated: true, completion: nil)
            }
        }
    }

}
