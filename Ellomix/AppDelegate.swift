//
//  AppDelegate.swift
//  Ellomix
//
//  Created by Akshay Vyas on 12/19/16.
//  Copyright © 2016 Akshay Vyas. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Soundcloud
import FacebookCore
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var storyboard: UIStoryboard?
    private var FirebaseAPI: FirebaseApi!
    private var fcmToken: String!
    lazy var loadingIndicatorView: LoadingViewController = {
        return self.storyboard?.instantiateViewController(withIdentifier: "loadingViewController") as! LoadingViewController
        }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FirebaseAPI = FirebaseApi()
        
        // Global appearance configuration
        UINavigationBar.appearance().tintColor = .black
        
        // Spotify
        setupSpotify()
        
        // Soundcloud
        Soundcloud.clientIdentifier = "3e7f2924c47462bf79720ae5995194de"
        
        // Music Player configuration
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        loginOrHome()
        
        // Notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        return true
    }
    
    func setupSpotify() {
        SPTAuth.defaultInstance().clientID = Constants.clientID
        SPTAuth.defaultInstance().redirectURL = Constants.redirectURI
        SPTAuth.defaultInstance().sessionUserDefaultsKey = Constants.sessionKey
        
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserLibraryReadScope]
        
        // Start the player
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: Constants.clientID)
        } catch {
            fatalError("Couldn't start Spotify SDK")
        }
    }
    
    // This function is called when the app is opened by a URL
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Check if this URL was sent from the Spotify app or website
        if SPTAuth.defaultInstance().canHandle(url) {
            
            // Send out a notification which we can listen for in our sign in view controller
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.authURLOpened, object: url)
            
            return true
        }
        
        return false
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("FCM Token: \(refreshedToken)")
            fcmToken = refreshedToken
        }
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Login and Home screen initialization
    func loginOrHome() {
        // Comment out to force user to log in
        storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let window = self.window {
            Auth.auth().addStateDidChangeListener() { auth, user in
                if (user != nil)  {
                    user!.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            print("Error grabbing authentication token: \(error)")
                            let getStartedNavController = self.storyboard?.instantiateViewController(withIdentifier: "getStartedNavController")
                            window.rootViewController = getStartedNavController
                        } else {
                            self.loadUser(user: user!)
                        }
                    }
                } else {
                    // User must login
                    let getStartedNavController = self.storyboard?.instantiateViewController(withIdentifier: "getStartedNavController")
                    window.rootViewController = getStartedNavController
                }
            }
        }
    }
    
    func loadUser(user: Firebase.User) {
        FirebaseAPI.getUsersRef().observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            //TODO: Handle edge case when users are authenticated with Firebase but don't have accounts
            if (snapshot.hasChild(user.uid)) {
                print("User was loaded from Firebase")
                
                let results = snapshot.value as! Dictionary<String, AnyObject>
                let userData = results[user.uid] as! Dictionary<String, AnyObject>
                
                self.setUser(userData: userData, uid: user.uid)
            } else if (AccessToken.current != nil) {
                print("Fetching profile from Facebook.")
                self.fetchProfileFromFB(user: user)
            }
        })
    }
    
    func setUser(userData: Dictionary<String, AnyObject>, uid: String) {
        let name = userData["name"] as? String
        let photoUrl = userData["photo_url"] as? String
        let website = userData["website"] as? String
        let bio = userData["bio"] as? String
        let email = userData["email"] as? String
        let gender = userData["gender"] as? String
        let birthday = userData["birthday"] as? String
        let followersCount = userData["followers_count"] as? Int
        let followingCount = userData["following_count"] as? Int
        let groups = userData["groups"] as? Dictionary<String, AnyObject>
        let deviceToken = userData["device_token"] as? String
        
        let loadedUser = EllomixUser(uid: uid)
        loadedUser.setName(name: name!)
        loadedUser.profilePicture.downloadedFrom(link: photoUrl)
        loadedUser.setProfilePicLink(link: photoUrl!)
        if (website != nil) { loadedUser.setWebsite(website: website!) }
        if (bio != nil) { loadedUser.setBio(bio: bio!) }
        if (email != nil) { loadedUser.setEmail(email: email!) }
        if (gender != nil) { loadedUser.setGender(gender: gender!) }
        if (birthday != nil) { loadedUser.setBirthday(birthday: birthday!)}
        if (followersCount != nil) { loadedUser.setFollowersCount(count: followersCount!) }
        if (followingCount != nil) { loadedUser.setFollowingCount(count: followingCount!) }
        if (groups != nil) { loadedUser.groups = Array(groups!.keys)}
        if (deviceToken != fcmToken) {
            self.FirebaseAPI.updateUserDeviceToken(uid: uid, token: fcmToken)
        } else {
            loadedUser.deviceToken = deviceToken
        }

        Global.sharedGlobal.user = loadedUser
        loadHomeScreen()
    }
    
    func fetchProfileFromFB(user: Firebase.User) {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        GraphRequest(graphPath: "me",
                     parameters: parameters,
                     accessToken: AccessToken.current,
                     httpMethod: .GET,
                     apiVersion: .defaultVersion).start { (urlResponse, requestResult) in
                        switch requestResult {
                        case .failed(let error):
                            print(error)
                            break
                        case .success(let graphResponse):
                            if let responseDict = graphResponse.dictionaryValue {
                                let firstName = responseDict["first_name"] as? String
                                let lastName = responseDict["last_name"] as? String
                                let name = firstName! + " " + lastName!
                                
                                let newUser = EllomixUser(uid: user.uid)
                                newUser.setName(name: name)
                                
                                if let picture = responseDict["picture"] as? NSDictionary {
                                    if let data = picture["data"] as? NSDictionary {
                                        if let urlString = data["url"] as? String {
                                            let url = URL(string: urlString)
                                            let data = try? Data(contentsOf: url!)
                                            DispatchQueue.main.async {
                                                let image =  UIImage(data: data!)
                                                newUser.setProfilePic(image: image!)
                                                self.FirebaseAPI.updateUserProfilePicture(user: newUser, image: image!) {
                                                    self.FirebaseAPI.updateUser(user: newUser)
                                                    Global.sharedGlobal.user = newUser
                                                    self.loadHomeScreen()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.FirebaseAPI.updateUser(user: newUser)
                                    Global.sharedGlobal.user = newUser
                                    self.loadHomeScreen()
                                }
                            }
                            
                            break
                        }
        }
    }
    
    func loadHomeScreen() {
        let containerController = storyboard?.instantiateViewController(withIdentifier: "containerController")
        window?.rootViewController = containerController
    }
    
    //MARK: Loading helper methods
    func showLoadingScreen(parentVC: UIViewController, message: String) {
        DispatchQueue.main.async {
            self.loadingIndicatorView.setMessage(forLabel: message)
            self.loadingIndicatorView.showLoadingIndicator(parent: parentVC)
        }
    }
    
    func dismissLoadingScreen() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.dismissLoadingIndicator()
        }
    }

}

