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

//protocol EventCreationDelegate: AnyObject {
//    func createdEvent(_ event: Event)
//}

class CreateEvents: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventDesc: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventStartTime: UIDatePicker!
    @IBOutlet weak var eventEndTime: UIDatePicker!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventActivityType: UITextField!
    @IBOutlet weak var eventNumPeople: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
    let db = Firestore.firestore()
    var eventsThatUserCreated: [String] = []
    var eventsThatUserIsAttending: [String] = []
    var currNumOfAttendees = 0

    @IBOutlet weak var mapView: MKMapView!

    let geocoder = CLGeocoder() //convert address to coordinates
    var selectedLocation: CLLocationCoordinate2D? //stores coordinates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventLocation.delegate = self
        mapView.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == eventLocation {
            searchLocation()
        }
    }
    
    func searchLocation() {
        guard let address = eventLocation.text, !address.isEmpty else {return}
        
        //convert address string to coordinates
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in guard let self = self else {return}
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first, let location = placemark.location
            else {
                print("No location found")
                return
            }
            self.selectedLocation = location.coordinate
            self.updateMap(with: location.coordinate)
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
    
    func updateMap(with geoPoint: GeoPoint) {
        let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        updateMap(with: coordinate)
    }
    
    
    @IBAction func uploadPhotoPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
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
            } else {
                print("Document does not exist")
            }
            
            // Prepare event data for Firestore
            var eventData: [String: Any] = [
                "title": self.eventTitle.text ?? "",
                "description": self.eventDesc.text ?? "",
                "date": self.eventDate.date,
                "startTime": self.eventStartTime.date,
                "endTime": self.eventEndTime.date,
                "location": self.eventLocation.text ?? "",
                "activities": self.eventActivityType.text ?? "",
                "numPeople": Int(self.eventNumPeople.text ?? "0") ?? 0,
                "hostUsername": hostUsername,
                "hostPfp": hostPfp,
                "hostId": userId,
                "eventPic": "",
                "eventID": "",
                "currentnumberofattendees": 0
            ]
            
            //add location coordinates to eventData
            if let coordinate = self.selectedLocation {
                eventData["coordinate"] = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }

            // Step 1: Create a document reference with a unique ID
            let documentReference = self.db.collection("events").document()

            // Step 2: Set the data with the document reference
            documentReference.setData(eventData) { error in
                if error != nil {
                    print("error")
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

extension CreateEvents:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

