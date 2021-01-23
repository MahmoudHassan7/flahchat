//
//  ViewController.swift
//  Flash Chat
//
//  Created by Mahmoud Hassab on 29/12/2020.


import UIKit
import Firebase
import ChameleonFramework
class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    
    var messageObjects : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self;
        messageTableView.dataSource = self;
        messageTextfield.delegate = self;
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        
        tableRowHeight()
        
        let tabGeustre = UITapGestureRecognizer(target: self, action: #selector(Tapped))
        messageTableView.addGestureRecognizer(tabGeustre)
        self.retreiveMessage()
    }
    
    
    
    @objc func Tapped()
    {
        messageTextfield.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: retrieve message
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        messageTextfield.endEditing(true);
        messageTextfield.isEnabled = false;
        sendButton.isEnabled = false;
        
        
        let dbMessages = Database.database().reference().child("Messages")
        let dictionary = ["Sender" : Auth.auth().currentUser?.email , "Message" : messageTextfield.text!]
        
        dbMessages.childByAutoId().setValue(dictionary) {
            (error, reference) in
            if(error != nil)
            {
                print(error)
                
            }
                
            else
            {
                print("message sent successfully")
                self.messageTextfield.isEnabled = true;
                self.sendButton.isEnabled = true;
                self.messageTextfield.text = "";
                
                
                self.tableRowHeight()
                self.messageTableView.reloadData()
            }
            
            
        }
        return true
    }
    
    
    
    func tableRowHeight()
    {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageObjects.count
        
    }
    
    
    //MARK: load messages to tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageObjects[indexPath.row].message
        cell.senderUsername.text = messageObjects[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if(cell.senderUsername.text == Auth.auth().currentUser?.email as String!)
        {
            cell.messageBackground.backgroundColor = UIColor.flatMint()
            cell.avatarImageView.backgroundColor = UIColor.flatSkyBlue()
            
        }
            
        else
        {
            cell.messageBackground.backgroundColor = UIColor.flatWatermelon()
            cell.avatarImageView.backgroundColor = UIColor.flatGray()
        }
        
        
        return cell;
        
        
    }
    
    
    // MARK: Send messages to Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true);
        messageTextfield.isEnabled = false;
        sendButton.isEnabled = false;
        
        
        let dbMessages = Database.database().reference().child("Messages")
        let dictionary = ["Sender" : Auth.auth().currentUser?.email , "Message" : messageTextfield.text!]
        
        dbMessages.childByAutoId().setValue(dictionary) {
            (error, reference) in
            if(error != nil)
            {
                print(error)
                
            }
                
            else
            {
                print("message sent successfully")
                self.messageTextfield.isEnabled = true;
                self.sendButton.isEnabled = true;
                self.messageTextfield.text = "";
                
                
                self.tableRowHeight()
                self.messageTableView.reloadData()
            }
            
            
        }
        
    }
    
    //MARK:  retrieveMessages
    
    func retreiveMessage()
    {
        let dbMessages = Database.database().reference().child("Messages")
        dbMessages.observe(.childAdded) { (SnapShot) in
            let snapshotValue = SnapShot.value as! Dictionary <String,String>
            let textMessage = snapshotValue["Message"]!;
            let sender = snapshotValue["Sender"]!;
            
            
            let message = Message();
            message.message = textMessage;
            message.sender = sender;
            self.messageObjects.append(message)
            self.tableRowHeight()
            self.messageTableView.reloadData()
            
            
        }
    }
    
    
    
    //MARK: Log out the user and send them back to WelcomeViewController
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        
        do{
            
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            
        }
        
        
    }
    
    
    
}
