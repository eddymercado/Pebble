//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit


class selectInterestsViewController: UIViewController {
    var count = 0;
    let activities = allActivities.shared.globalActivities

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //     sender.isSelected.toggle()
    //     sender.backgroundColor = sender.isSelected ? UIColor.systemBlue : UIColor.systemGray2


    @IBAction func genericPush(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        if sender.isSelected {
            sender.backgroundColor = UIColor.systemBlue
            count = count + 1
            print(count)
            
            // allActivities.shared.addGlobalActivity("Soccer")   // check if over 5
            // let userData:
            // Analytics.setUserProperty(arrayOfInterests, forName: "Zip Code")
            if count > 5 {
                showAlert(title: "Only 5 interests can be selected", message: "")
                count = count - 1
                print(count)
                sender.isSelected.toggle()
                sender.backgroundColor = UIColor.systemGray2
            }
        } else {
            sender.backgroundColor = UIColor.systemGray2
            // remove from array
            count = count - 1
            print(count)
        }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
        
    }

    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
