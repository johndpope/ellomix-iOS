//
//  AddMemberController.swift
//  Ellomix
//
//  Created by Kevin Avila on 7/21/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class AddMemberController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchUsersView: UIView!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
        searchTextView.delegate = self
        
        let border = CALayer()
        border.frame = CGRect.init(x: 0, y: searchUsersView.frame.height, width: searchUsersView.frame.width, height: 1)
        border.backgroundColor = UIColor.lightGray.cgColor
        searchUsersView.layer.addSublayer(border)
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
    
    //MARK: TableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: Navigation Bar functions
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }
}
