//
//  RSVPTableViewCell.swift
//  Pebble
//
//  Created by Tesna Thomas on 11/27/24.
//

import UIKit

class RSVPTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
