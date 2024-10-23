//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit

class selectInterestsViewController: UIViewController {
    
    @IBOutlet weak var toggleSoccerButton: UIButton!
    var isSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        toggleSoccerButton.backgroundColor = UIColor.systemGray2
    }
    
    @IBAction func toggleButtonPressed(_ sender: UIButton) {
            isSelected.toggle()  // Toggle the selected state

        if isSelected {
            toggleSoccerButton.backgroundColor = UIColor.systemBlue
        } else {
            toggleSoccerButton.backgroundColor = UIColor.systemGray2
        }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
        
    }
    

}
