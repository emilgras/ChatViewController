//
//  ChatCell.swift
//  ChatViewController
//
//  Created by Emil Gräs on 11/09/2016.
//  Copyright © 2016 Emil Gräs. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    var message: Message? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func updateUI() {
        if let message = message {
            self.nameLabel.text = message.author
            self.messageLabel.text = message.message
        }
    }

}
