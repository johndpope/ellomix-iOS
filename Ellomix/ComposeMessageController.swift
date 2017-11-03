//
//  ComposeMessageController.swift
//  Ellomix
//
//  Created by Kevin Avila on 10/29/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Alamofire
import Soundcloud

class ComposeMessageController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull friends and list in table view
    }
    
    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func cancelMessage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
