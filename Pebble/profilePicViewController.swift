//
//  profilePicViewController.swift
//  Pebble
//
//  Created by Denise Ramos on 10/21/24.
//

import UIKit

class profilePicViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func profilePicSaveButton(_ sender: Any) {
        performSegue(withIdentifier: "profilePicToSelectInterests", sender: self)
        }
    }



