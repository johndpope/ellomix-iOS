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
    var members: [Dictionary<String, AnyObject>]?
    let sections = ["Name", "Notifications", "Members", "Leave"]
    
    override func viewDidLoad() {
        members = group.users?.omitCurrentUser()
        if let count = group.users?.count {
            if (count > 2) {
               groupChat = true
            }
        }
        
        tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "leaveGroupCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationsCell")
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }
    
    //Mark: Table View functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (groupChat && sections[section] == "Members") {
            return (members?.count)! + 1
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!groupChat || sections[indexPath.section] == "Notifications") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationsCell", for: indexPath) as! SwitchTableViewCell
            cell.label.text = cell.toggle.isOn ? "On" : "Off"
            
            return cell
        } else if (sections[indexPath.section] == "Name") {
            return UITableViewCell()
        } else if (sections[indexPath.section] == "Members") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            if (indexPath.row == 0) {
                cell.userLabel.text = "Add Member"
                cell.userImageView.image = #imageLiteral(resourceName: "attach")
            } else if (members != nil) {
                let user = members![indexPath.row - 1]
                cell.userLabel.text = user["name"] as? String
                if let photoURL = user["photo_url"] as? String, !photoURL.isEmpty {
                    cell.userImageView.downloadedFrom(link: photoURL)
                } else {
                    cell.userImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveGroupCell", for: indexPath) as! LabelTableViewCell
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
