//
//  NewMessageTableViewController.swift
//  Qchat
//
//  Created by Rauan Zhakypbek on 1/9/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

    // MARK: - Model
    var users = [User]()
    let imageCache = NSCache<NSString, UIImage>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .white
        fetchUserList()
    }
    
    func fetchUserList() {
        DispatchQueue.global(qos: .userInteractive).async {   [weak self] in
            Database.database().reference().child("users").observe(.childAdded) { (dataSnapshot) in
                if let firebaseUser = dataSnapshot.value as? [String:String] {
                    let name = firebaseUser["name"] ?? "No name"
                    let email = firebaseUser["email"] ?? "No email"
                    let urlPath = firebaseUser["profileImageURL"] ?? ""
                    let url = urlPath == "" ? nil : URL(string: urlPath)
                    let uid = firebaseUser["uid"] ?? "No ID"
                    self?.users.append(User(name: name, email: email, profileImageURL: url, uid: uid))
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
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
    
    
    @IBAction func cancelNewMessage(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.nameLabel.text = users[indexPath.row].name
        cell.emailLabel.text = users[indexPath.row].email
        cell.profileImageView.layer.cornerRadius = 35
        cell.profileImageView.backgroundColor = .white
        cell.profileImageView.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 4
        cell.layer.borderColor = UIColor.white.cgColor
        cell.uid = users[indexPath.row].uid
        fetchImageAndSet(imageURL: users[indexPath.row].profileImageURL, view: cell.profileImageView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        if segue.identifier == "showChat" {
            if let destinationVC = segue.destination as? ChatTableViewController, let senderCell = sender as? UserTableViewCell {
                destinationVC.navigationItem.title = senderCell.nameLabel.text
                destinationVC.chatPartnerID = senderCell.uid
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
