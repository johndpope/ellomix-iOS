//
//  GroupSettingsController.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class GroupSettingsTableViewController: UITableViewController {
    
    var group: Group!
    var groupChat: Bool = false
    let sections = ["Name", "Notifications", "Members", "Leave"]
    
    override func viewDidLoad() {
        if let count = group.users?.count {
            if (count > 2) {
               groupChat = true
            }
        }
        
        let nib = UINib(nibName: "SimpleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "simpleCell")
    }
    
    //Mark: Table View functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (groupChat && sections[section] == "Members") {
            return (group.users?.count)!
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!groupChat) {
            return UITableViewCell()
        }
        
        if (sections[indexPath.section] == "Name") {
            return UITableViewCell()
        } else if (sections[indexPath.section] == "Notifications") {
            return UITableViewCell()
        } else if (sections[indexPath.section] == "Members") {
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleTableViewCell
            cell.label.text = "Leave Group"

            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (groupChat) {
            return sections.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (groupChat) {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: "groupSettingsHeaderCell") as! GroupSettingsHeaderCell
            headerCell.sectionTitleLabel.text = sections[section]
            
            return headerCell
        }
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "groupSettingsHeaderCell") as! GroupSettingsHeaderCell
        headerCell.sectionTitleLabel.text = sections[1]
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (sections[section] == "Leave") {
            return 0
        }
        
        return 18
    }
}
