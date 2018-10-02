//
//  SelectUsersOrGroupsController.swift
//  Ellomix
//
//  Created by Kevin Avila on 9/28/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SelectUsersOrGroupsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var groupsAndFollowingUsers = [AnyObject]()
    var filteredGroupsAndFollowingUsers = [AnyObject]()
    var selected:[String:Bool] = [:]
    let searchController = UISearchController(searchResultsController: nil)
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser?
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user

        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true

        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        groupsAndFollowingUsers.removeAll()
        retrieveGroupsAndUsers()
    }

    @IBAction func dismissButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func retrieveGroupsAndUsers() {
        FirebaseAPI.getFollowingRef().child("\((currentUser?.uid)!)").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            var userDict = snapshot.value as? Dictionary<String, AnyObject>
            userDict!["uid"] = snapshot.key as AnyObject
            if let ellomixUser = userDict!.toEllomixUser() {
                self.groupsAndFollowingUsers.append(ellomixUser)
                self.filteredGroupsAndFollowingUsers.append(ellomixUser)
                self.selected[ellomixUser.uid] = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //TODO: Retrieve groups
    }
    
    //Mark: Table View functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroupsAndFollowingUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userOrGroup = filteredGroupsAndFollowingUsers[indexPath.row]
        
        if (userOrGroup is EllomixUser) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            let ellomixUser = userOrGroup as! EllomixUser
            
            cell.userLabel.text = ellomixUser.getName()
            if (!ellomixUser.profilePicLink.isEmpty) {
                cell.userImageView.downloadedFrom(link: ellomixUser.profilePicLink)
            } else {
                cell.userImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            }
            
            return cell
        } else {
            // Set group cell
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: Searchbar
    func updateSearchResults(for searchController: UISearchController) {
        if (!(searchController.searchBar.text!.isEmpty)) {
            filterGroupsAndUsers(searchText: searchController.searchBar.text!)
        } else {
            filteredGroupsAndFollowingUsers = groupsAndFollowingUsers
        }

        tableView.reloadData()
    }
    
    //MARK: Helpers
    func filterGroupsAndUsers(searchText: String) {
        filteredGroupsAndFollowingUsers = groupsAndFollowingUsers.filter { groupOrUser in
            var name = ""
            if (groupOrUser is EllomixUser) {
                let user = groupOrUser as! EllomixUser
                name = user.getName()
            } else {
                // Parse group name
            }
            return name.lowercased().contains(searchText.lowercased())
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }
}
