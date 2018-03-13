//
//  ComposeMessageController.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/29/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Alamofire
import Soundcloud

class ComposeMessageController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?


    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var followingUsers = [Dictionary<String, AnyObject>?]()
    var filteredUsers = [Dictionary<String, AnyObject>?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        tableView.dataSource = self
        tableView.delegate = self
        searchTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.followingUsers.removeAll()
        retrieveFollowingUsers()
    }
    
    func retrieveFollowingUsers() {
        FirebaseAPI.getFollowingRef().child("\((currentUser?.uid)!)").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            self.followingUsers.append(snapshot.value as? Dictionary)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "composeMessageCell", for: indexPath) as! ComposeMessageTableViewCell

        let user = filteredUsers[indexPath.row]
        cell.userNameLabel.text = user!["name"] as? String
        if (user!["photo_url"] as? String == "" || user!["photo_url"] == nil) {
            cell.userProfilePic.image = #imageLiteral(resourceName: "ellomix_logo_bw")
        } else {
            DispatchQueue.global().async {
                let url = user!["photo_url"]! as? String
                let data = try? Data(contentsOf: URL(string: url!)!)
                DispatchQueue.main.async {
                    cell.userProfilePic.image = UIImage(data: data!)
                    cell.userProfilePic.layer.cornerRadius = cell.userProfilePic.frame.size.width / 2
                    cell.userProfilePic.clipsToBounds = true
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func cancelNewMessage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Text View functions
    func textViewDidChange(_ textView: UITextView) {
        filterUsers(searchText: textView.text!)
        tableView.reloadData()
    }
    
    //MARK: Helpers
    func filterUsers(searchText: String) {
        filteredUsers = followingUsers.filter{ user in
            let name = user!["name"] as? String
            return (name?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
}
