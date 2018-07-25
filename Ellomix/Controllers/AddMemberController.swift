//
//  AddMemberController.swift
//  Ellomix
//
//  Created by Kevin Avila on 7/21/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class AddMemberController: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            navigationBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        navigationBar.delegate = self
    }
    
    @IBAction func cancelAddMember(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
