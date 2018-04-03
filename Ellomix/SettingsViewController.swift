//
//  settingsViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 3/18/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

<<<<<<< HEAD
import UIKit
import Firebase
import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, UITableViewDelegate {
=======
import Foundation
import UIKit

class SettingsViewController: UITableViewController {

    //linked accounts
    
    //change password
    
    //make account private
>>>>>>> 4c5270cf60fa8bcffd8d9f061c872ea61589dc8f
    
    @IBOutlet weak var logoutButton: UIButton
    private var FirebaseAPI: FirebaseApi!
    var currentUser:EllomixUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAPI = FirebaseApi()
        
        FirebaseAPI.getUsersRef()
            .child((currentUser?.uid)!)
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
    func openblog(){
    UIApplication.shared.open(URL(string : "http://www.Ellomix.com")!, options: [:], completionHandler: { (status) in
        })
    }
    
    //clear search history --> push button
    
    //logout
    //TODO:Change to IBACTION
    func logoutPushed() {
        //facebook
        if(FBSDKAccessToken.current() !== nil){
            FBSDKLoginManager().logOut()
            logout();
        } else {
            Auth.auth().currentUser == nil
            logout()
        }
    
    }
    
    func logout() {
        print("logout function")
        let storyboard = UIStoryboard(name: "login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginController")
        self.present(vc, animated: true, completion: nil)
    }

}
