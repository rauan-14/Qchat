//
//  Message.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/10/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import Foundation

struct Message {
    let senderID: String
    let receiverID: String
    let message: String
    let time: String
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.receiverID == rhs.receiverID && lhs.senderID == rhs.senderID
}
