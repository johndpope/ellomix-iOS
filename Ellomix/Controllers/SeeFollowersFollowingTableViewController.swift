//
//  SeeFollowersFollowingTableViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 9/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SeeFollowersFollowingTableViewController: UITableViewController {

    var users: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(users)
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
            if let photoURL = user!["photo_url"] as? String, !photoURL.isEmpty {
                cell.userImageView.downloadedFrom(link: photoURL)
            } else {
                cell.userImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
