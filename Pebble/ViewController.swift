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

class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"
    let createEventsSegueIdentifier = "createEventsSegueIdentifier"
    let db = Firestore.firestore()
    var eventsIamAttending: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let curruser = user?.uid {
                self.fetchAllEvents()
            } else {
                eventsList.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.dataSource = self
        collectionView.delegate = self

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            if let curruser = user?.uid {
                self.fetchAllEvents()
            } else {
                eventsList.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchAllEvents() {

        
        guard let curruser = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(curruser).getDocument(source: .default) { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                self.eventsIamAttending = document.get("eventsThatUserIsAttending") as? [String] ?? []
                print("here1")
                print(self.eventsIamAttending)
                
                self.db.collection("events").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching documents: \(error)")
                    } else {
                        // Clear eventsList to avoid duplications
                        eventsList.removeAll()
                        
                        // Loop through each document in the collection
                        for document in querySnapshot!.documents {
                            // Assuming each document has a field "name" or "title" of type String
                            if let eventID = document.get("eventID") as? String {
                                print(self.eventsIamAttending)
                                if(!self.eventsIamAttending.contains(eventID)) {
                                    // maybe sort by sometihng !!
                                    if let userId = document.get("hostId") as? String, userId != curruser {
                                        eventsList.append(eventID) // Add event name to the array
                                    }
                                }
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
    
    func presentSingleEventVC(selectedEvent: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let segueVC = storyboard.instantiateViewController(withIdentifier: "SingleEventViewController") as? SingleEventViewController {
            segueVC.currEventID = selectedEvent
            segueVC.modalPresentationStyle = .popover
            
            // Set the popover's delegate to self
            if let popoverController = segueVC.popoverPresentationController {
                popoverController.delegate = self
            }
            
            self.present(segueVC, animated: true, completion: nil)
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        collectionView.dataSource = self
        collectionView.delegate = self

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            if let curruser = user?.uid {
                self.fetchAllEvents()
            } else {
                eventsList.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? UICollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            print("Cell tapped at index: \(indexPath.item)")
            let selectedEvent = eventsList[indexPath.item]

            presentSingleEventVC(selectedEvent: selectedEvent)
        }
    }

}
