//
//  CreateEvents.swift
//  Pebble
//
//  Created by Katherine Chao on 10/21/24.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseAnalytics
import FirebaseFirestoreInternal

class CreateEvents: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDesc: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventEndTime: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventActivityTypeButton: UIButton! // UIButton for activity type
    @IBOutlet weak var eventNumPeople: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoPic: UIImageView!
    
    let db = Firestore.firestore()
    let geocoder = CLGeocoder()
    
    var eventsThatUserCreated: [String] = []
    var eventsThatUserIsAttending: [String] = []
    var currNumOfAttendees = 0
    var selectedLocation: CLLocationCoordinate2D?
    let activityTypes = [
        "⚽️ Soccer", "🏃‍♀️ Running", "📕 Reading", "🎾 Pickleball", "🥮 Celebrations",
        "🧑‍🍳 Cooking", "🎮 Gaming", "🐕 Animals", "🥾 Outdoors", "👒 Gardening",
        "🧘‍♂️ Yoga", "🍽️ Food", "🏀 Basketball", "🎨 Art", "🎓 College", "🎶 Music",
        "📖 Writing", "📸 Photography", "🎥 Movies", "🌍 Traveling", "🏋️‍♀️ Fitness",
        "🍩 Baking", "🎉 Parties", "🎲 Misc", "🏌️‍♀️ Golf", "🎊 Culture", "🌊 Swimming"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventLocation.delegate = self
        mapView.delegate = self
        roundOutViews() // rounds out UI
    }
    
    // rounds out elements in UI
    func roundOutViews() {
        eventActivityTypeButton.layer.cornerRadius = 5
        eventActivityTypeButton.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.layer.masksToBounds = true
        eventImageView.layer.cornerRadius = 5
        eventImageView.layer.masksToBounds = true
        logoPic.layer.cornerRadius = 5
        logoPic.layer.masksToBounds = true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == eventLocation {
            searchLocation()
        }
    }
    
    func searchLocation() {
        guard let address = eventLocation.text, !address.isEmpty else { return }
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("No location found")
                return
            }
            self.selectedLocation = location.coordinate
            self.updateMap(with: location.coordinate)
        }
    }
    
    func updateMap(with coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = eventLocation.text
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func activityTypeButtonTapped(_ sender: UIButton) {
        let dropdownVC = DropdownViewController()
        dropdownVC.activityTypes = activityTypes
        dropdownVC.modalPresentationStyle = .popover
        dropdownVC.popoverPresentationController?.sourceView = sender
        dropdownVC.popoverPresentationController?.sourceRect = sender.bounds
        dropdownVC.popoverPresentationController?.delegate = self
        dropdownVC.popoverPresentationController?.permittedArrowDirections = .up
        dropdownVC.onActivitySelected = { [weak self] selectedActivity in
            self?.eventActivityTypeButton.setTitle(selectedActivity, for: .normal)
        }
        present(dropdownVC, animated: true)
    }
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func createEventBtnPressed(_ sender: UIButton) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument(source: .default) { (document, error) in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }

            var hostUsername = "temp"
            var hostPfp = "temp"
            var eventPic = "temp"
            var currEventID = "temp"
            
            if let document = document, document.exists {
                hostPfp = document.get("profilePic") as? String ?? "temp"
                hostUsername = document.get("username") as? String ?? "temp"
                self.eventsThatUserCreated = document.get("eventsThatUserIsHosting") as? Array ?? []
                self.eventsThatUserIsAttending = document.get("eventsThatUserIsAttending") as? Array ?? []
            }
            
            var eventData: [String: Any] = [
                "title": self.eventTitle.text ?? "",
                "description": self.eventDesc.text ?? "",
                "date": self.eventDate.date,
                "startTime": self.eventStartTime.date,
                "endTime": self.eventEndTime.date,
                "location": self.eventLocation.text ?? "",
                "activities": self.eventActivityTypeButton.currentTitle ?? "",
                "numPeople": Int(self.eventNumPeople.text ?? "0") ?? 0,
                "hostUsername": hostUsername,
                "hostPfp": hostPfp,
                "hostId": userId,
                "eventPic": "",
                "eventID": "",
                "currentnumberofattendees": 1,
                "peopleAttending": [userId]   // Add the host to the peopleAttending list
            ]
            
            if let coordinate = self.selectedLocation {
                eventData["coordinate"] = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }

            let documentReference = self.db.collection("events").document()
            documentReference.setData(eventData) { error in
                if error != nil {
                    print("Error creating event.")
                } else {
                    currEventID = documentReference.documentID

                    if let image = self.eventImageView.image,
                       let imageData = image.jpegData(compressionQuality: 0.5) {
                        let base64String = imageData.base64EncodedString()
                        eventPic = base64String
                        self.db.collection("events").document(currEventID).updateData(["eventPic": eventPic])
                    }
                    
                    self.db.collection("events").document(currEventID).updateData(["eventID": currEventID])
                    self.eventsThatUserCreated.append(currEventID)
                    self.eventsThatUserIsAttending.append(currEventID)
                    self.db.collection("users").document(userId).updateData(["eventsThatUserIsHosting": self.eventsThatUserCreated])
                    self.db.collection("users").document(userId).updateData(["eventsThatUserIsAttending": self.eventsThatUserIsAttending])
                    self.db.collection("events").document(currEventID).updateData(["currentnumberofattendees": 1])
                
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let segueVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController {
                        segueVC.modalPresentationStyle = .fullScreen
                        self.present(segueVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension CreateEvents: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension CreateEvents: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let eventPic = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            eventImageView.image = eventPic
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
