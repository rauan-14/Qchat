//
//  ViewController.swift
//  ChatDemo
//
//  Created by Rauan Zhakypbek on 1/8/18.
//  Copyright © 2018 Rauan Zhakypbek. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton! {
        didSet{
            loginButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Mark: - Constraints
    @IBOutlet weak var heightOfName: NSLayoutConstraint!
    
    @IBOutlet weak var heightOfTextFieldsContainer: NSLayoutConstraint!
        
    // Mark: - Actions
    @IBAction func switchLoginRegister(_ sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        //shrink textfield container if needed
        heightOfTextFieldsContainer.constant = sender.selectedSegmentIndex == 1 ? 115 : 150
        heightOfName.constant = sender.selectedSegmentIndex == 1 ? 0 : 35
        loginButton.setTitle(title, for: .normal)
    }

    
    @IBAction func RegisterOrLogin(_ sender: UIButton) {
        let actionType = sender.currentTitle
        if actionType == "Register" {
            registerUser()
        } else {
            login()
        }
    }
    
    func registerUser() {
        guard let email = emailTextField.text,
            let name = nameTextField.text,
            let password = passwordTextField.text else { return }
        
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            let alert = UIAlertController(title: "Incomplete info", message: "Please enter missing fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (firebaseUser, error) in
            if error != nil {
                return
            }
            guard let uid  = firebaseUser?.uid else { return }
            let storageReference = Storage.storage().reference().child("profile_images").child(uid).child("profile_image.png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!.compressTo(1) ?? self.profileImageView.image!)
            {
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                    }
                    let profileImageURL = metadata?.downloadURL()?.absoluteString ?? ""
                    let ref = Database.database().reference(fromURL: "https://qchat-ed137.firebaseio.com/")
                    let userReference = ref.child("users").child(uid)
                    let values = ["name":name, "email":email, "profileImageURL": profileImageURL, "uid" : uid] as [String : String]
                    userReference.updateChildValues(values)
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func login() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        guard !email.isEmpty, !password.isEmpty else {
            let alert = UIAlertController(title: "Invalid info", message: "Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (firebaseUser, error) in
            if error != nil {
                let alert = UIAlertController(title: "Invalid info", message: "Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    func setupViews(){
        emailTextField.text = nil
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setProfileImage)))
        profileImageView.isUserInteractionEnabled = true
    }
    @objc func setProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print(originalImage.size)
            profileImageView.image = originalImage
            dismiss(animated: true, completion: nil)
        }
    }
}

import UIKit

extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = UIImageJPEGRepresentation(self, compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
}




