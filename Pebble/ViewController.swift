//
//  ViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/14/24.
//

import UIKit

class ViewController: UIViewController {
    
    let profilePageSegueIdentifier = "ProfilePageSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Sends info to ProfilePage View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profilePageSegueIdentifier {
            if let nextVC = segue.destination as? ProfilePage {
                nextVC.delegate = self
            }
        }
    }

}

