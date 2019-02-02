//
//  TimelineTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/2/19.
//  Copyright © 2019 Akshay Vyas. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController {
    
    var baseDelegate: ContainerViewController!
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateNewPost") {
            let navVC = segue.destination as! UINavigationController
            let segueVC = navVC.topViewController as! SearchSongsTableViewController
            //segueVC.delegate = self
            segueVC.doneButton.title = "Next"
        }
    }
}
