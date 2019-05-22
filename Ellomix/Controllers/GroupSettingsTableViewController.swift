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
    var baseDelegate: ContainerViewController!
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
        
        leaveGroupAlert = UIAlertController(title: "Leave group?", message: "The group conversation and playlist will be deleted from your inbox.", preferredStyle: .alert)
        leaveGroupAlert!.addAction(UIAlertAction(title: "Leave", style: .default, handler: leaveGroup))
        leaveGroupAlert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "leaveGroupCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationsCell")
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.register(UINib(nibName: "FieldTableViewCell", bundle: nil), forCellReuseIdentifier: "nameCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseDelegate.playBarViewBottomConstraint.constant = -(self.tabBarController?.tabBar.frame.height)!
        var membersDictionary = group.users!
        membersDictionary.removeValue(forKey: (currentUser?.uid)!)
        members = membersDictionary.usersArray()
        if let count = group.users?.count {
            if (count > 2) {
                groupChat = true
            }
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        baseDelegate.playBarViewBottomConstraint.constant = 0
        if (leavingGroup) {
            currentUser?.groups.removeValue(forKey: group.gid!)
            group.users?.removeValue(forKey: (currentUser?.uid)!)
            FirebaseAPI.leaveGroupChat(group: group, uid: (currentUser?.uid)!)
        } else {
            saveSettings()
        }
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
            cell.toggle.isOn = currentUser!.groups[group.gid!]!
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
                cell.userImageView.downloadedFrom(link: user["photo_url"] as? String)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveGroupCell", for: indexPath) as! LabelTableViewCell
            cell.label.text = "Leave Group"

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sections[indexPath.section] == "Members") {
            if (indexPath.row == 0) {
                self.performSegue(withIdentifier: "toAddMember", sender: nil)
            }
        } else if (sections[indexPath.section] == "Leave") {
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
        currentUser!.groups[group.gid!] = cell.toggle.isOn
        
        FirebaseAPI.updateGroupChat(group: group, user: currentUser!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddMember") {
            let segueVC = segue.destination as! AddMemberController
            segueVC.group = group
            segueVC.delegate = self
        }
    }
    
}
