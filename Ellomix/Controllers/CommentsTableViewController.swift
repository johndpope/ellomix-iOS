//
//  PostDetailController.swift
//  Ellomix
//
//  Created by Kevin Avila on 6/27/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
    
    private var FirebaseAPI: FirebaseApi!
    var pid: String!
    
    var comments = [Comment]()
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseAPI.getPostComments(pid: pid, completion: { (comments) in
            self.comments = comments
        })
    }
}
