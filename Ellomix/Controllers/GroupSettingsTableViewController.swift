//
//  GroupSettingsController.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class GroupSettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    var doneButton: UIBarButtonItem!
    var currentUser: EllomixUser?
    var group: Group!
    var groupChat: Bool = false
    var leavingGroup: Bool = false
    var members: [Dictionary<String, AnyObject>]?
    var delegate: ChatViewController?
    var leaveGroupAlert: UIAlertController?
    let sections = ["Name", "Notifications", "Members", "Leave"]
    
    private var FirebaseAPI: FirebaseApi!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        doneButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
        navigationItem.title = "Details"
        var membersDictionary = group.users!
        membersDictionary.removeValue(forKey: (currentUser?.uid)!)
        members = membersDictionary.usersArray()
        if let count = group.users?.count {
            if (count > 2) {
               groupChat = true
            }
        }
        
        leaveGroupAlert = UIAlertController(title: "Leave group?", message: "The group conversation and playlist will be deleted from your inbox.", preferredStyle: .alert)
        leaveGroupAlert!.addAction(UIAlertAction(title: "Leave", style: .default, handler: leaveGroup))
        leaveGroupAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "leaveGroupCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationsCell")
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.register(UINib(nibName: "FieldTableViewCell", bundle: nil), forCellReuseIdentifier: "nameCell")
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
            if let users = group.users {
                if let userInfo = users[currentUser!.uid] as? Dictionary<String, AnyObject> {
                    if let notifications = userInfo["notifications"] as? Bool {
                        cell.toggle.isOn = notifications
                    }
                }
            }
            cell.label.text = cell.toggle.isOn ? "On" : "Off"
            
            return cell
        } else if (sections[indexPath.section] == "Name") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! FieldTableViewCell
            cell.textField.delegate = self
            if (group.name == nil || group.name!.isEmpty) {
                cell.textField.textColor = .lightGray
                cell.textField.text = "Enter a group name..."
            } else {
                cell.textField.textColor = .black
                cell.textField.text = group.name!
            }
            
            return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sections[indexPath.section] == "Leave") {
            self.present(leaveGroupAlert!, animated: true)
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
        
        return 20
    }
    
    //MARK: Text Field Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! FieldTableViewCell
        group.name = cell.textField.text
        view.endEditing(true)
        navigationItem.rightBarButtonItem = nil
    }
    
    func leaveGroup(alert: UIAlertAction!) {
        leavingGroup = true
        navigationController?.popToRootViewController(animated: true)
    }
    
    func saveSettings() {
        if (delegate != nil) {
            delegate!.group = group
        }
        
        let notificationsSection = groupChat ? 1 : 0
        let notificationsIndexPath = IndexPath(row: 0, section: notificationsSection)
        let cell = tableView.cellForRow(at: notificationsIndexPath) as! SwitchTableViewCell
        if (group.users != nil) {
            var userInfo = group.users![currentUser!.uid] as? Dictionary<String, AnyObject>
            userInfo!["notifications"] = cell.toggle.isOn as AnyObject
            group.users![currentUser!.uid] = userInfo as AnyObject
        }
        
        FirebaseAPI.updateGroupChat(group: group)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (leavingGroup) {
            if let index = currentUser?.groups.index(of: group.gid!) {
                currentUser?.groups.remove(at: index)
                group.users?.removeValue(forKey: (currentUser?.uid)!)
                FirebaseAPI.leaveGroupChat(group: group, uid: (currentUser?.uid)!)
            }
        } else {
            saveSettings()
        }
    }
}
