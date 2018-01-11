//
//  ChatTableViewController.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/10/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // MARK: - Model
    var messages = [Message]() {
        didSet {
            chatTableView.reloadData()
            showLastMessages()
        }
    }
    
    var chatPartnerID : String? = nil
    
    // MARK: Firebase/Database
    
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            chatTableView.delegate = self
            chatTableView.dataSource = self
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if let messageText = messageTextField.text, !messageText.isEmpty {
            let currentTime = Date().description
            let newMessage = Message(senderID: Auth.auth().currentUser!.uid, receiverID: chatPartnerID!, message: messageText, time: currentTime)
            // messages.append(newMessage)
            sendToDatabase(newMessage)
            messageTextField.text?.removeAll()
            chatTableView.reloadData()
            showLastMessages()
        }
    }
    @IBOutlet weak var messageTextField: UITextField!
    
    
    func fetchMessages() {
        if let uid = Auth.auth().currentUser?.uid {
            DispatchQueue.global(qos: .userInitiated).async {   [weak self] in
                Database.database().reference().child("messages").child(uid).child(self!.chatPartnerID!).observe(.childAdded) { (dataSnapshot) in
                    if let firebaseMessage = dataSnapshot.value as? [String:String] {
                        let messageText = firebaseMessage["message"] ?? ""
                        let senderID = firebaseMessage["senderID"] ?? ""
                        let receiverID = firebaseMessage["receiverID"] ?? ""
                        let time = firebaseMessage["time"] ?? "0"
                        self?.messages.append(Message(senderID: senderID, receiverID: receiverID, message: messageText, time: time))
                        DispatchQueue.main.async {
                            self?.chatTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func sendToDatabase(_ message: Message) {
        let messageValues = ["message":message.message, "senderID": message.senderID, "receiverID": message.receiverID, "time": message.time]
        let messageReference = Database.database().reference().child("messages").child(message.senderID).child(message.receiverID).child(message.time)
        messageReference.updateChildValues(messageValues)
        Database.database().reference().child("messages").child(message.senderID).child("lastMessages").child(message.receiverID).updateChildValues(messageValues)
        let receiverMessageReference = Database.database().reference().child("messages").child(message.receiverID).child(message.senderID).child(message.time)
        receiverMessageReference.updateChildValues(messageValues)
        Database.database().reference().child("messages").child(message.receiverID).child("lastMessages").child(message.senderID).updateChildValues(messageValues)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        fetchMessages()
    }

    override func viewWillLayoutSubviews() {
        chatTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let uid = Auth.auth().currentUser?.uid, messages[indexPath.row].senderID == uid {
            let messageCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
            messageCell.messageText.text = messages[indexPath.row].message
            messageCell.messageText.layer.cornerRadius = 5
            messageCell.messageText.layer.masksToBounds = true
            messageCell.messageText.numberOfLines = 0
            //messageCell.messageText.numberOfLines = messageCell.messageText.numberOfVisibleLines
            messageCell.messageContainerWidth.constant = view.frame.width * 2/3
            messageCell.messageText.textColor = .white
            messageCell.backgroundContainer.layer.cornerRadius = 5
            messageCell.backgroundContainer.layer.masksToBounds = true
            messageCell.selectionStyle = .none
            return messageCell
        }
        let receiverMessageCell = tableView.dequeueReusableCell(withIdentifier: "receiverMessageCell") as! ReceiverMessageTableViewCell
        receiverMessageCell.messageText.text = messages[indexPath.row].message
        receiverMessageCell.messageText.layer.cornerRadius = 5
        receiverMessageCell.messageText.layer.masksToBounds = true
        receiverMessageCell.messageText.numberOfLines = 0
        //receiverMessageCell.messageText.numberOfLines = receiverMessageCell.messageText.numberOfVisibleLines
        receiverMessageCell.messageContainerWidth.constant = view.frame.width * 2/3
        receiverMessageCell.messageText.textColor = .white
        receiverMessageCell.backgroundContainer.layer.cornerRadius = 5
        receiverMessageCell.backgroundContainer.layer.masksToBounds = true
        receiverMessageCell.selectionStyle = .none
        return receiverMessageCell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = messages[indexPath.row].message
        return text.height(constraintedWidth: view.frame.width * 2/3, font: UIFont.systemFont(ofSize: 17)) + 40
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func showLastMessages() {
        if chatTableView.numberOfRows(inSection: 0) > 1 {
        let lastRow: Int = chatTableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0);
        chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        }
    }
    
}



extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}


