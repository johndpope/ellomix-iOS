//
//  HomeTabController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/30/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController, SearchSongsDelegate, SharePostDelegate {
    
    var searchSongsNavController: UINavigationController!
    var sharePostController: SharePostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab bar appearance setup
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)

        // Initialize SharePostController
        let sharePostStoryboard = UIStoryboard(name: "SharePost", bundle: nil)
        sharePostController = sharePostStoryboard.instantiateViewController(withIdentifier: "sharePostController") as? SharePostController
    }
    
    //MARK: SearchSongsDelegate
    func doneSelecting(selected: [BaseTrack]) {
        sharePostController.track = selected.first
        sharePostController.sharePostDelegate = self
        searchSongsNavController.pushViewController(sharePostController, animated: true)
    }
    
    //MARK: SharePostDelegate
    func didSharePost(sharePostVC: SharePostController) {
        // Go back to Home and refresh
        selectedIndex = 0
        if let navController = viewControllers?[0] as? UINavigationController {
            let timelineVC = navController.topViewController as! TimelineTableViewController
            timelineVC.refreshTimeline(self)
        }
        
        
        // Reset Post screen
        sharePostVC.navigationController?.popViewController(animated: false)
        if let searchSongsVC = searchSongsNavController.topViewController as? SearchSongsTableViewController {
            searchSongsVC.searchController.searchBar.text = ""
            searchSongsVC.searchController.searchBar.resignFirstResponder()
            searchSongsVC.clearSongs()
            searchSongsVC.tableView.reloadData()
        }
    }
    
}
