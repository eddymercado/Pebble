//
//  SingleEventViewController.swift
//  Pebble
//
//  Created by Katherine Chao on 11/11/24.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseStorage

class SingleEventViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    let geocoder = CLGeocoder()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var eventMonth: UILabel!
    @IBOutlet weak var eventDay: UILabel!
    @IBOutlet weak var eventDayName: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var activityType: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var rsvpbutton: UIButton!
    @IBOutlet weak var eventPic: UIImageView!
    @IBOutlet weak var deleteEvent: UIButton!
    @IBOutlet weak var editEventButton: UIButton!
    
    @IBOutlet weak var firstRectangle: UIView!
    @IBOutlet weak var secondRectangle: UIView!
    
    var RSVPButtonPressedCheck  = false
    var eventsThatUserIsAttending: [String] = []
    let db = Firestore.firestore()
//    var currUser = ""
    //var numberOfGuests, increase when someone RSVPs, decrease when leave

    var currEventID = ""
    var hostName = ""
    var currNum = 0
    var didIComeFromProfilePage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
        if(didIComeFromProfilePage) {
            RSVPButtonPressedCheck = true
            self.rsvpbutton.setTitle("Leave", for: .normal)
        }
        checkIfUserIsHostForEdits()
    }
    
    func checkIfUserIsHostForEdits() {
        guard let currentUserID = Auth.auth().currentUser?.uid, !currEventID.isEmpty else {
            editEventButton.isHidden = true
            return
        }
        
        db.collection("events").document(currEventID).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                self.editEventButton.isHidden = true
                return
            }
            guard let document = document, document.exists, let hostID = document.data()?["hostId"] as? String else {
                    self.editEventButton.isHidden = true
                    return
                }
            
            if currentUserID == hostID {
                self.editEventButton.isHidden = false
            } else {
                self.editEventButton.isHidden = true
            }
        }
    }
    
    func updateMap(with coordinate: CLLocationCoordinate2D) {
        //create region centered on location
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        //create and add annotation for location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = eventLocation.text
        //remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }
    
    func updateUI() {

        db.collection("events").document(currEventID).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                
                if let base64String = document.get("eventPic") as? String {
                    // Convert the Base64 string to UIImage
                    
                    if let image = self.decodeBase64ToImage(base64String) {
                        self.eventPic.image = image // Set the decoded image in an UIImageView
                        self.eventPic.contentMode = .scaleAspectFill
                    }
                }
                
                if let eventTitle = document.get("title") as? String {
                    self.eventTitle.text = eventTitle
                }
                if let eventHost = document.get("hostUsername") as? String {
                    self.eventHost.text = eventHost
                }
                
                if let timestamp = document.get("date") as? Timestamp {
                    let date = timestamp.dateValue()
                    let calendar = Calendar.current

                    // Extract individual components
                    let month = calendar.component(.month, from: date) // Numeric month (e.g., 11 for November)
                    let dayInt = calendar.component(.day, from: date)     // Day of the month (e.g., 27)
                    let day = String(dayInt)
                    let year = calendar.component(.year, from: date)   // Full year (e.g., 2024)
                    
                    // Get abbreviated month name
                    let monthAbbreviation = calendar.shortMonthSymbols[month - 1] // "Nov" for 11
                    
                    // Get the day name (e.g., "Saturday", "Friday")
                    let dayFormatter = DateFormatter()
                    dayFormatter.dateFormat = "EEEE" // Full day name
                    let dayName = dayFormatter.string(from: date)
                    
                    // set date labels
                    self.eventMonth.text = monthAbbreviation
                    self.eventDay.text = day
                    self.eventDayName.text = dayName
                }
                
                // convert event start time from timestamp to string
                if let timestamp = document.get("startTime") as? Timestamp {
                    let time = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short // Customize the format
                    self.eventStartTime.text = formatter.string(from: time)
                }
                
                // convert event end time from timestamp to string
                if let timestamp = document.get("endTime") as? Timestamp {
                    let time = timestamp.dateValue()
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short // Customize the format
                    self.eventEndTime.text = formatter.string(from: time)
                }
                
                if let eventDescription = document.get("description") as? String {
                    self.eventDescription.text = eventDescription
                }
                if let eventLocation = document.get("location") as? String {
                    self.eventLocation.text = eventLocation
                }

                if let geoPoint = document.get("coordinate") as? GeoPoint {
                      let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    self.updateMap(with: coordinate)
                  }
                if let currNum = document.get("currentnumberofattendees") as? Int {
                    self.currNum = currNum
                }
                if let currAct = document.get("activities") as? String {
                    self.activityType.text = currAct
                }
                
                // round out edges of UI
                self.activityType.layer.cornerRadius = 10
                self.activityType.layer.masksToBounds = true
                self.firstRectangle.layer.cornerRadius = 10
                self.firstRectangle.layer.masksToBounds = true
                self.secondRectangle.layer.cornerRadius = 10
                self.secondRectangle.layer.masksToBounds = true
                self.mapView.layer.cornerRadius = 10
                self.mapView.layer.masksToBounds = true
            } else {
                print("Document does not exist")
            }
            
        }
    }

    @IBAction func editEventButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "HostEditEventSegue", sender: self)
    }
    
    @IBAction func RSVPButtonPressed(_ sender: Any) {
        RSVPButtonPressedCheck = !RSVPButtonPressedCheck
        
        //get curr event
        // get current user
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument(source: .default) { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                self.eventsThatUserIsAttending = document.get("eventsThatUserIsAttending") as? Array ?? []
            }
            
            // NEED TO PUT IN NUM ATTENDEES CHECK ALERT
            
            // IS RSVP
            if(self.RSVPButtonPressedCheck) {
                self.rsvpbutton.setTitle("Leave", for: .normal)
                self.eventsThatUserIsAttending.append(self.currEventID)
                self.db.collection("users").document(userId).updateData(["eventsThatUserIsAttending": self.eventsThatUserIsAttending])
                self.db.collection("events").document(self.currEventID).updateData(["currentnumberofattendees": self.checkNumOfAttendees() + 1])
                // Add user ID to the list of RSVPed users
                self.db.collection("events").document(self.currEventID).updateData([
                    "peopleAttending": FieldValue.arrayUnion([userId])
                ])
            }
            
            // UN RSVP
            else {
                
                let alertController = UIAlertController(title: "Are you sure you want to remove yourself from this event?", message: "", preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                    if let index = self.eventsThatUserIsAttending.firstIndex(of: self.currEventID) {
                        self.eventsThatUserIsAttending.remove(at: index)
                    }
                    self.rsvpbutton.setTitle("RSVP", for: .normal)
                    self.db.collection("users").document(userId).updateData(["eventsThatUserIsAttending": self.eventsThatUserIsAttending])
                    self.db.collection("events").document(self.currEventID).updateData(["currentnumberofattendees": self.checkNumOfAttendees() - 1])
                    // Remove user ID from the list of RSVPed users
                    self.db.collection("events").document(self.currEventID).updateData([
                        "rsvpUsers": FieldValue.arrayRemove([userId])
                    ])
                }
                
                let noAction = UIAlertAction(title: "No", style: .cancel)
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)


            }
        }
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func checkNumOfAttendees() -> Int {
        db.collection("events").document(currEventID).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                if let currNum = document.get("currentnumberofattendees") as? Int {
                    self.currNum = currNum
                }
            }
        }
        return currNum
    }
    
    // Shows list of people attending event
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToRSVPList" {
            if let destinationVC = segue.destination as? RSVPTableViewController {
                destinationVC.eventID = currEventID // Pass the event ID
            }
        } else if segue.identifier == "HostEditEventSegue" {
            if let createEventsVC = segue.destination as? CreateEvents {
                createEventsVC.isEditMode = true
                createEventsVC.eventIDToEdit = currEventID
            }
        }
    }
    
}
