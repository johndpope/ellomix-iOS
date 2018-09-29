//
//  SelectUsersOrGroupsController.swift
//  Ellomix
//
//  Created by Kevin Avila on 9/28/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SelectUsersOrGroupsController: UITableViewController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }
    
    @IBAction func dismissButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
