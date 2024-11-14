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

class SingleEventViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate {
    
    let geocoder = CLGeocoder()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocation: UILabel!

    @IBOutlet weak var eventPic: UIImageView!
    
    var currEventID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateUI()
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
                if let eventDate = document.get("date") as? String {
                    self.eventDate.text = eventDate
                }
                if let eventTime = document.get("startTime") as? String {
                    self.eventTime.text = eventTime
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
                
            } else {
                print("Document does not exist")
            }
            
        }
        
    }



}
