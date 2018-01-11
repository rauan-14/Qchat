//
//  ViewController.swift
//  
//
//  Created by Rauan Zhakypbek on 1/9/18.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    let imageCache = NSCache<NSString, UIImage>()

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBAction func logout(_ sender: Any?) {
        try! Auth.auth().signOut()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "showLoginRegisterMenu", sender: nil)
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    func setupViews() {
        if let uid = Auth.auth().currentUser?.uid {
            let snapshotRef =  Database.database().reference().child("users").child(uid)
            snapshotRef.observeSingleEvent(of: .value , with: { [weak self ] snapshot in
                if let userInfo = snapshot.value as? [String:String] {
                    self?.email.text = userInfo["email"]
                    self?.name.text = userInfo["name"]
                    if let url = userInfo["profileImageURL"] {
                        self?.fetchImageAndSet(imageURL: URL(string: url) , view: self?.profileImage)
                    }
                }
            })
        }
    }

    
    private func fetchImageAndSet(imageURL: URL?, view: UIImageView?) {
        if let url = imageURL, let view = view {
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        if let dowloadedImage = UIImage(data: imageData) {
                            view.image = dowloadedImage
                            self.imageWidth.constant = dowloadedImage.size.width / dowloadedImage.size.height * 160
                            view.layer.cornerRadius = 5
                            view.layer.masksToBounds = true
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
            view?.image = #imageLiteral(resourceName: "noImage")
        }
    }
    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLoginRegisterMenu" {
            logout(nil)
        }
    }
 
}
