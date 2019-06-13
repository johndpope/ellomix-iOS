//
//  SeeFollowersFollowingTableViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 9/27/18.
//  Copyright © 2018 Ellomix. All rights reserved.
//

import UIKit
import Firebase

class SeeFollowersFollowingTableViewController: UITableViewController {

    var users: [Any] = []
    private var FirebaseAPI: FirebaseApi!
    var baseDelegate:ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        if (indexPath.item < (self.users.count)) {
            let user = self.users[indexPath.item] as? Dictionary<String, Any>
            cell.userLabel.text = user!["name"] as? String
            cell.userImageView.downloadedFrom(link: user!["photo_url"] as? String)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.item] as? Dictionary<String, Any>
        let uid = user!["uid"] as? String
        
        FirebaseAPI.getUser(uid: uid!) { (user) -> () in
            self.performSegue(withIdentifier: "toProfile", sender: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            if let user = sender as? EllomixUser {
                let userProfileVC = segue.destination as! ProfileController
                userProfileVC.baseDelegate = baseDelegate
                userProfileVC.currentUser = user
            }
        }
    }
}
