//
//  ProfilePage.swift
//  Pebble
//
//  Created by Tesna Thomas on 10/17/24.
//

import UIKit

class ProfilePage: UIViewController {
    
    var delegate: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get screen dimensions
                let screenSize = UIScreen.main.bounds
                
                // Create a UIView for the bottom half
                let bottomHalfView = UIView()
                bottomHalfView.frame = CGRect(x: 0, y: screenSize.height / 2, width: screenSize.width, height: screenSize.height / 2)
                
                // Set the background color
                bottomHalfView.backgroundColor = UIColor.gray
                
                // Add the view to the main view
                self.view.addSubview(bottomHalfView)
    }
}
