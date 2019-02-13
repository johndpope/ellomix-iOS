//
//  TimelineTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/2/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, SearchSongsDelegate {
    
    var baseDelegate: ContainerViewController!
    
    override func viewDidLoad() {
        
    }
    
    func doneSelecting(selected: [String : Dictionary<String, AnyObject>]) {
        let navVC = presentedViewController as! UINavigationController
        let searchSongsVC = navVC.topViewController as! SearchSongsTableViewController
        searchSongsVC.performSegue(withIdentifier: "toSharePost", sender: nil)
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
