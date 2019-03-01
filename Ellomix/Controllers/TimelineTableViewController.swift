//
//  TimelineTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/2/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, SearchSongsDelegate {
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser!
    var baseDelegate: ContainerViewController!
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        retrieveTimeline()
    }
    
    func retrieveTimeline() {
        FirebaseAPI.getUserTimeline(uid: currentUser.uid, completion: { (snapshot) in
            print(snapshot)
        })
    }
    
    //MARK: SearchSongsDelegate
    
    func doneSelecting(selected: [String : Dictionary<String, AnyObject>]) {
        let navVC = presentedViewController as! UINavigationController
        let searchSongsVC = navVC.topViewController as! SearchSongsTableViewController
        searchSongsVC.performSegue(withIdentifier: "toSharePost", sender: nil)
    }
    
    //MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateNewPost") {
            let navVC = segue.destination as! UINavigationController
            let segueVC = navVC.topViewController as! SearchSongsTableViewController
            segueVC.searchSongsDelegate = self
            segueVC.selectLimit = 1
        }
    }
}
