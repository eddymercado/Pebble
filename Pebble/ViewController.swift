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
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownTableView: UITableView!
    @IBOutlet weak var dropdownHeightConstraint: NSLayoutConstraint!
    
    var selectedInterests: Set<String> = [] // Keep track of selected interests
    let activityTypes = [
        "⚽️ Soccer", "🏃‍♀️ Running", "📕 Reading", "🎾 Pickleball", "🥮 Celebrations",
        "🧑‍🍳 Cooking", "🎮 Gaming", "🐕 Animals", "🥾 Outdoors", "👒 Gardening",
        "🧘‍♂️ Yoga", "🍽️ Food", "🏀 Basketball", "🎨 Art", "🎓 College", "🎶 Music",
        "📖 Writing", "📸 Photography", "🎥 Movies", "🌍 Traveling", "🏋️‍♀️ Fitness",
        "🍩 Baking", "🎉 Parties", "🎲 Misc", "🏌️‍♀️ Golf", "🎊 Culture", "🌊 Swimming"
    ]
    
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
        
        self.logoImage.layer.cornerRadius = 5
        self.logoImage.layer.masksToBounds = true
        
        dropdownView.isHidden = true
        dropdownTableView.dataSource = self
        dropdownTableView.delegate = self
        
        // Register a basic UITableViewCell
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
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
    
    @IBAction func filterInterestsButtonPressed(_ sender: Any) {
        dropdownView.isHidden.toggle() // Toggle visibility
    }

    @IBAction func applyButtonTapped(_ sender: Any) {
        dropdownView.isHidden = true
        filterEvents(by: Array(selectedInterests))
    }
    
    func filterEvents(by interests: [String]) {
        guard !interests.isEmpty else {
            fetchAllEvents() // Reload all events if no interests are selected
            return
        }
        
        eventsList.removeAll() // Clear previous results
        
        let group = DispatchGroup()
        
        // Query for each selected interest individually
        for interest in interests {
            group.enter()
            db.collection("events")
                .whereField("activities", isEqualTo: interest) // Match single interest field
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error filtering events: \(error.localizedDescription)")
                    } else {
                        for document in querySnapshot!.documents {
                            if let eventID = document.get("eventID") as? String {
                                eventsList.append(eventID)
                            }
                        }
                    }
                    group.leave()
                }
        }
        
        // Reload collection view after all queries complete
        group.notify(queue: .main) {
            self.collectionView.reloadData()
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
                                if(!self.eventsIamAttending.contains(eventID)) {
                                    // maybe sort by sometihng !!
                                    if let userId = document.get("hostId") as? String, userId != curruser {
                                        eventsList.append(eventID) // Add event name to the array
                                    }
                                }
                            }
                        }
                        
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
            let selectedEvent = eventsList[indexPath.item]
            presentSingleEventVC(selectedEvent: selectedEvent)
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        let interest = activityTypes[indexPath.row]
        
        cell.textLabel?.text = interest
        cell.accessoryType = selectedInterests.contains(interest) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let interest = activityTypes[indexPath.row]
        
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

