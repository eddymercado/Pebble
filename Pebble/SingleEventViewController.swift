//
//  SingleEventViewController.swift
//  Pebble
//
//  Created by Katherine Chao on 11/11/24.
//

import UIKit

class SingleEventViewController: UIViewController {
    var event: Event?
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventHost: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventLocation: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("event in SingleEventViewController: \(event)")
        updateUI()
    }
    
    func updateUI() {
        guard let event = event else {
            print("no event data")
            return
        }
        
        eventTitle.text = event.title
        //event host
        eventDate.text = DateFormatter.localizedString(from: event.date, dateStyle: .medium, timeStyle: .none)
//        eventTime.text =
        eventDescription.text = event.description
        eventLocation.text = event.location
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
