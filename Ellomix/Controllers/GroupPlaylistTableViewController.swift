//
//  GroupPlaylistTableViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/25/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class GroupPlaylistTableViewController: UITableViewController {
    
    var emptyPlaylistButton = UIButton()
    var emptyPlaylistLabel = UILabel()
    var emptyPlaylistView = UIView()

    var songs = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: TableView functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (songs.count == 0) {
            emptyPlaylistButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
            emptyPlaylistButton.setTitle("Add Songs", for: .normal)
            emptyPlaylistButton.backgroundColor = UIColor.ellomixBlue()
            emptyPlaylistButton.circular()
            emptyPlaylistButton.center = tableView.center
            emptyPlaylistView.addSubview(emptyPlaylistButton)
            
//            emptyPlaylistLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            emptyPlaylistLabel.text = "Put the group on to some new songs."
//            emptyPlaylistView.addSubview(emptyPlaylistLabel)
            
            tableView.backgroundView = emptyPlaylistView
        } else {
            tableView.backgroundView = nil
        }
        
        return 1
    }


}
