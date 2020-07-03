//
//  ViewController.swift
//  Flash Chat

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    var messageArr : [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource
        messageTableView.delegate = self //self = chat view controller
        messageTableView.dataSource = self
    
        
        //TODO: Set yourself as the delegate of the text field
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped)) //detect tap gesture inside the table view (i.e. outside of the keyboard)
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register MessageCell.xib file. bundle = file path
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
       
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    
    //MARK:- TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //custom cell for the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArr[indexPath.row].messageBody
        cell.senderUsername.text = messageArr[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == (Auth.auth().currentUser?.email)! as String {
            //msgs I sent
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        } else {
            //msgs others sent
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArr.count 
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //Make the cell height automatically adjust to the message label content size
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    
    //MARK:- TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded() //reload when one constant is modified
        }
    }
    
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false //don't allow the user to type when sending a msg to the database
        sendButton.isEnabled = false //disable the send button
        
        let messagesDB = Database.database().reference().child("Messages") //create a messages child database inside the main database
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        
        //create a custom random key for each msg so each msg can be saved with a unique identifier
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("Message stored.")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in //a snapshot of the database
            
            let snapshotValue = snapshot.value as! Dictionary<String, String> //set value type to dictionary
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArr.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut() //signOut() may throw an error
            navigationController?.popToRootViewController(animated: true) //root view controller = welcome view controller. animated: true = have the animation on screen
        }
        catch{
            print("error")
        }
    }
    


}
