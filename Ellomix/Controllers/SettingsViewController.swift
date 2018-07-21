//
//  SettingsViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 3/18/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import Firebase

class SettingsViewController: UITableViewController {
    @IBOutlet weak var blogButton: UIButton!
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //make account private: TODO:
    //change and add a private field and if so ONLY SHOW ON PRIVATE MATTERS ETC>>> FIRBASE STUFF FILTER ON AND OFF
    func makeAccountPrivate(){
        //button pressed 
        //firebase --> then private
    }
    
    //push notifications:
    //push to the phone? message alerts?
    
    //blog
    //TODO:Change to IBACTION
    @IBAction func openBlog(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://ellomix.com/blog/index.html")!)

    }
    
    //clear search history --> push button
    
    
    @IBAction func logout(_ sender: Any) {
        if (AccessToken.current != nil) {
            LoginManager().logOut()
        }
        
        do {
            try Auth.auth().signOut()
            if let window = UIApplication.shared.delegate?.window {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let getStartedNavController = storyboard.instantiateViewController(withIdentifier: "getStartedNavController")
                window!.rootViewController = getStartedNavController
            }
        } catch let signOutError {
            print ("Error signing out of Firebase: \(signOutError)")
        }
    }

}
