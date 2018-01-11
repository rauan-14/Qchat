//
//  LastMessageTableViewCell.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/11/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit

class LastMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var partnerID:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
