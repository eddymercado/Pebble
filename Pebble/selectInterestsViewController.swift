//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit

class selectInterestsViewController: UIViewController {
    
    @IBOutlet weak var toggleSoccerButton: UIButton!
    var isSoccerSelected: Bool = false
    
    @IBOutlet weak var toggleRunningButton: UIButton!
    var isRunningSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        toggleSoccerButton.backgroundColor = UIColor.systemGray2
        toggleRunningButton.backgroundColor = UIColor.systemGray2
    }
    
    @IBAction func soccerPressed(_ sender: UIButton) {
            isSoccerSelected.toggle()  // Toggle the selected state

        if isSoccerSelected {
            toggleSoccerButton.backgroundColor = UIColor.systemBlue
        } else {
            toggleSoccerButton.backgroundColor = UIColor.systemGray2
        }
    }
    
    @IBAction func runningPressed(_ sender: UIButton) {
            isRunningSelected.toggle()  // Toggle the selected state

        if isRunningSelected {
            toggleRunningButton.backgroundColor = UIColor.systemBlue
        } else {
            toggleRunningButton.backgroundColor = UIColor.systemGray2
        }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        
        performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
        
    }
    

}
