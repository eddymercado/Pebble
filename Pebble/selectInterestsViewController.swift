//
//  selectInterestsViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit
//let instanceForArray = Event()

class selectInterestsViewController: UIViewController {
    var count = 0;
    
    @IBOutlet weak var toggleSoccerButton: UIButton!
    var isSoccerSelected: Bool = false
    
    @IBOutlet weak var toggleRunningButton: UIButton!
    var isRunningSelected: Bool = false
    
    @IBOutlet weak var toggleBookButton: UIButton!
    var isBookSelected: Bool = false
    
    @IBOutlet weak var togglePickleballButton: UIButton!
    var isPickleballSelected: Bool = false

    @IBOutlet weak var toggleCelebrationsButton: UIButton!
    var isCelebrationsSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        toggleSoccerButton.backgroundColor = UIColor.systemGray2
        toggleRunningButton.backgroundColor = UIColor.systemGray2
        toggleBookButton.backgroundColor = UIColor.systemGray2
        togglePickleballButton.backgroundColor = UIColor.systemGray2
        toggleCelebrationsButton.backgroundColor = UIColor.systemGray2
    }
    
    
    // for every function check if 5 are slected if so show alert
    // add to array
    @IBAction func soccerPressed(_ sender: UIButton) {
        isSoccerSelected.toggle()  // Toggle the selected state
        if isSoccerSelected {
            toggleSoccerButton.backgroundColor = UIColor.systemBlue
            count = count + 1
//            instanceForArray.array.append("Soccer")
            // check if over 5
            if fiveIsLimit() {
                count = count - 1
                // instanceForArray.array.remove() FIX
                print(count)
                showAlert(title: "Only 5 interests can be selected", message: "")
                isSoccerSelected.toggle()
            }
        } else {
            toggleSoccerButton.backgroundColor = UIColor.systemGray2
            // remove from array
            count = count - 1
        }
    }
    
    @IBAction func runningPressed(_ sender: UIButton) {
            isRunningSelected.toggle()  // Toggle the selected state

        if isRunningSelected {
            toggleRunningButton.backgroundColor = UIColor.systemBlue
            count = count + 1
            // check if over 5
            if fiveIsLimit() {
                count = count - 1
                showAlert(title: "Only 5 interests can be selected", message: "")
                isRunningSelected.toggle()
            }
        } else {
            toggleRunningButton.backgroundColor = UIColor.systemGray2
            count = count - 1
        }
    }
    
    @IBAction func bookPressed(_ sender: UIButton) {
            isBookSelected.toggle()  // Toggle the selected state

        if isBookSelected {
            toggleBookButton.backgroundColor = UIColor.systemBlue
            count = count + 1
            // check if over 5
            if fiveIsLimit() {
                count = count - 1
                showAlert(title: "Only 5 interests can be selected", message: "")
                isBookSelected.toggle()
            }
        } else {
            toggleBookButton.backgroundColor = UIColor.systemGray2
            count = count - 1
        }
    }
    
    @IBAction func pickleballPressed(_ sender: UIButton) {
            isPickleballSelected.toggle()  // Toggle the selected state

        if isPickleballSelected {
            togglePickleballButton.backgroundColor = UIColor.systemBlue
            count = count + 1
            // check if over 5
            if fiveIsLimit() {
                count = count - 1
                showAlert(title: "Only 5 interests can be selected", message: "")
                isPickleballSelected.toggle()
            }
        } else {
            togglePickleballButton.backgroundColor = UIColor.systemGray2
            count = count - 1
        }
    }
    
   
    @IBAction func celebrationsPressed(_ sender: UIButton) {
            isCelebrationsSelected.toggle()  // Toggle the selected state

        if isCelebrationsSelected {
            toggleCelebrationsButton.backgroundColor = UIColor.systemBlue
            count = count + 1
            print(count)
            // check if over 5
            if fiveIsLimit() {
                count = count - 1
                showAlert(title: "Only 5 interests can be selected", message: "")
                isCelebrationsSelected.toggle()
                print(count)
            }
        } else {
            toggleCelebrationsButton.backgroundColor = UIColor.systemGray2
            count = count - 1
            print(count)
        }
    }

    @IBAction func selectInterestToBrowseEvents(_ sender: Any) {
        
        performSegue(withIdentifier: "selectInterestToBrowseEvents", sender: self)
        
    }
    func fiveIsLimit() -> Bool {
        if count > 5 {
            return true
        }
        else {
            return false
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
