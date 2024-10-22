//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit

class selectInterestsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
        
    }
    

}
