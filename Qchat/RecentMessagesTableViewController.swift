//
//  RecentMessagesTableViewController.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/11/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit
import Firebase

class RecentMessagesTableViewController: UITableViewController {

    var recentMessages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }
    let imageCache = NSCache<NSString, UIImage>()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Recent Messages"
        tableView.separatorColor = UIColor.white
        fetchMessages()
    }
    
    func fetchMessages() {
        if let uid = Auth.auth().currentUser?.uid {
            DispatchQueue.global(qos: .userInitiated).async {   [weak self] in
                let recentMessagesReference = Database.database().reference().child("messages").child(uid).child("lastMessages")
                recentMessagesReference.observe(.childAdded) { (dataSnapshot) in
                    if let firebaseMessage = dataSnapshot.value as? [String:String] {
                        let messageText = firebaseMessage["message"] ?? ""
                        let senderID = firebaseMessage["senderID"] ?? ""
                        let receiverID = firebaseMessage["receiverID"] ?? ""
                        let time = firebaseMessage["time"] ?? "0"
                        self?.recentMessages.append(Message(senderID: senderID, receiverID: receiverID, message: messageText, time: time))
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
                
                recentMessagesReference.observe(.childChanged) { (dataSnapshot) in
                    if let firebaseMessage = dataSnapshot.value as? [String:String] {
                        let messageText = firebaseMessage["message"] ?? ""
                        let senderID = firebaseMessage["senderID"] ?? ""
                        let receiverID = firebaseMessage["receiverID"] ?? ""
                        let time = firebaseMessage["time"] ?? "0"
                        let index = self!.indexOfMessage(for: Message(senderID: senderID, receiverID: receiverID, message: messageText, time: time))
                        if index != nil {
                            self!.recentMessages.remove(at: index!)
                        }
                        self?.recentMessages.insert(Message(senderID: senderID, receiverID: receiverID, message: messageText, time: time), at: 0)
                        //self?.recentMessages.append(Message(senderID: senderID, receiverID: receiverID, message: messageText, time: time))
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    func indexOfMessage(for receivedMessage: Message)->Int? {
        for index in 0..<recentMessages.count {
            let message =  recentMessages[index]
            if message == receivedMessage {
                return index
            }
        }
        return nil
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recentMessages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lastMessage", for: indexPath) as! LastMessageTableViewCell
        let message = recentMessages[indexPath.row]
        let partnerID = Auth.auth().currentUser!.uid == message.senderID ? message.receiverID : message.senderID
        Database.database().reference().child("users").child(partnerID).observeSingleEvent(of: .value) { snapshot in
            if let firebaseUser = snapshot.value as? [String:String] {
                cell.nameLabel.text = firebaseUser["name"]
                let urlPath = firebaseUser["profileImageURL"]
                let url = urlPath == nil ? nil : URL(string: urlPath!)
                cell.profileImageView.layer.cornerRadius = 35
                cell.profileImageView.layer.masksToBounds = true
                self.fetchImageAndSet(imageURL: url, view: cell.profileImageView)
            }
        }
       
        cell.messageLabel.text = recentMessages[indexPath.row].message
        let time = recentMessages[indexPath.row].time
        let startIndex = time.index(time.startIndex, offsetBy: 11)
        let endIndex = time.index(startIndex, offsetBy: 8)
        let range = startIndex..<endIndex
        cell.timeLabel.text = String(time[range])
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.selectionStyle = .none
        cell.partnerID = Auth.auth().currentUser!.uid == recentMessages[indexPath.row].senderID ? recentMessages[indexPath.row].receiverID : recentMessages[indexPath.row].senderID
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    
    private func fetchImageAndSet(imageURL: URL?, view: UIImageView) {
        if let url = imageURL {
            //if it is in a cache
            if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
                view.image = cachedImage
                return
            }
            //if it is not in a cache
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        if let dowloadedImage = UIImage(data: imageData) {
                            view.image = dowloadedImage
                            self.imageCache.setObject(dowloadedImage, forKey: NSString(string: url.absoluteString))
                        }
                        else {
                            view.image = #imageLiteral(resourceName: "noImage")
                        }
                    }
                    else {
                        view.image = #imageLiteral(resourceName: "noImage")
                    }
                }
            }
        }
        else {
            view.image = #imageLiteral(resourceName: "noImage")
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatFromRecent" {
            if let destinationVC = segue.destination as? ChatTableViewController, let senderCell = sender as? LastMessageTableViewCell {
                destinationVC.navigationItem.title = senderCell.nameLabel.text
                destinationVC.chatPartnerID = senderCell.partnerID
            }
        }
    }
    

}
