//
//  MessageTableViewCell.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/10/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit

class ReceiverMessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var messageText: UILabel!
    
    @IBOutlet weak var messageContainerWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

