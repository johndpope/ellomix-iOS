//
//  ContainerViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 12/3/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    
    @IBOutlet weak var playBarView: UIView!
    
    override func viewDidLoad() {
        playBarView.isHidden = true
    }
    
    func activatePlaybar() {
        playBarView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeTabBarVC = segue.destination as? HomeTabBarController {
            if let navController = homeTabBarVC.viewControllers?.first as? UINavigationController {
                let searchVC = navController.topViewController as! SearchViewController
                searchVC.baseDelegate = self
            }
        }
    }
}
