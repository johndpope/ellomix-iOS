//
//  ChatFeedTableViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/16/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class ChatFeedTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    var chats: [FIRDataSnapshot]! = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //TODO: Implement code similar to Android
        configureDatabase()
    }
    
    deinit {
        if let refHandle = _refHandle  {
            self.ref.child("Chats").removeObserver(withHandle: refHandle)
        }
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        
        // Listen for new chats
        _refHandle = self.ref.child("Chats").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            // TODO: listen for new chats you been added/invited to
            guard let strongSelf = self else { return }
            strongSelf.chats.append(snapshot)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.chats.count - 1, section: 0)], with: .automatic)
        })
        // Listen for new messages

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ChatFeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatFeedTableViewCell
        
        //Get the chat at indexPath
        let index = indexPath.row
        let chatSnapshot : FIRDataSnapshot! = chats[index]
        
        // Unpack chat from Firebase Snapshot
        // TODO: Learn how to pack in an
        let chatRecipient = chatSnapshot.childSnapshot(forPath: "fromRecipient").value as? String ?? ""
        let chatLastMessage = chatSnapshot.childSnapshot(forPath: "mostRecentMessage").value as? String ?? ""
        
        // Configure the cell...
        cell.fromRecipientLabel?.text = chatRecipient
        cell.recentMessageLabel?.text = chatLastMessage
        cell.chatId = chatSnapshot.key

        return cell
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let segueVC : ChatViewController = segue.destination as! ChatViewController
        let cell : ChatFeedTableViewCell = self.tableView.cellForRow(at: (self.tableView.indexPathForSelectedRow)!) as! ChatFeedTableViewCell
        segueVC.chatId = cell.chatId
        
    }
 

}
