//
//  HomeTabController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/30/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab bar appearance setup
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    }
    
}
