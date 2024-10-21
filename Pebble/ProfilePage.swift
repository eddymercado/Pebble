//
//  ProfilePage.swift
//  Pebble
//
//  Created by Tesna Thomas on 10/17/24.
//

import UIKit

class ProfilePage: UIViewController {
    
    var delegate: ViewController!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProfilePic()
    }
    
    func setupUI() {
        view.backgroundColor = .systemGray6
    }

    func setupProfilePic() {
        profilePic.frame.size.width = profilePic.frame.size.height
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        view.addSubview(profilePic)
    }
}
