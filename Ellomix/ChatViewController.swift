//
//  ChatViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/21/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
, UITextFieldDelegate{

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    var ref: FIRDatabaseReference!
    var messages: [FIRDataSnapshot]! = []
    fileprivate var _refHandle: FIRDatabaseHandle!
    var chatId : String?
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if (messageTextField.text != "") {
            let data = ["text": messageTextField.text]
            sendMessage(withData: data as! [String : String])
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.isScrollEnabled = true
        messageTextField.delegate = self
        print(chatId!)
        configureDatabase()
    }
    
    deinit {
        self.ref.child("Chats")
            .child(chatId!)
            .child("messages")
            .removeObserver(withHandle: _refHandle)
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref
            .child("Chats")
            .child(chatId!)
            .child("messages")
            .observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.messages.append(snapshot)
            strongSelf.chatTableView.insertRows(at: [IndexPath(row: strongSelf.messages.count - 1, section: 0)], with: .automatic)
            strongSelf.chatTableView.scrollToRow(at: IndexPath(row: strongSelf.messages.count - 1, section: 0), at: UITableViewScrollPosition.top, animated: true)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // UITableViewDataSource protocol methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        
        // Unpack message from Firebase DataSnapshot
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        guard let message = messageSnapshot.value as? [String:String] else { return cell }
        
        let name = message["name"] ?? ""
        let text = message["text"] ?? ""
        
        cell.recipientLabel.text = name
        cell.messageLabel.text = text
        cell.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoURL = message["photoUrl"], let URL = URL(string: photoURL),
            let data = try? Data(contentsOf: URL) {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }
    
    // UITextViewDelegate protocol methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        textField.text = ""
        view.endEditing(true)
        let data = ["text": text]
        sendMessage(withData: data)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage(withData data: [String: String]) {
        var mdata = data
        mdata["name"] = "Anonymous"
        let photoURL : String? = nil
        mdata["photoUrl"] = photoURL
            
//            if let photoURL = FIRAuth.auth()?.currentUser?.photoURL {
//            mdata[Constants.MessageFields.photoURL] = photoURL.absoluteString
//        }
        
        // Push data to Firebase Database
    
        self.ref.child("Chats")
        .child(chatId!)
        .child("messages")
        .childByAutoId()
        .setValue(mdata)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
