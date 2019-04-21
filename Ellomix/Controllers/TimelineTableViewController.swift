//
//  TimelineTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/2/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, SearchSongsDelegate {
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser!
    var baseDelegate: ContainerViewController!
    var sharePostController: SharePostController!
    
    var posts = [Post]()

    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        let sharePostStoryboard = UIStoryboard(name: "SharePost", bundle: nil)
        sharePostController = sharePostStoryboard.instantiateViewController(withIdentifier: "sharePostController") as? SharePostController
        
        retrieveTimeline()
    }
    
    func retrieveTimeline() {
        FirebaseAPI.getUserTimeline(uid: currentUser.uid, completion: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let post = postDict.toPost() {
                    self.posts.append(post)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    //MARK: SearchSongsDelegate
    
    func doneSelecting(selected: [BaseTrack]) {
        let searchSongsNavVC = presentedViewController as! UINavigationController
        
        sharePostController.track = selected.first
        searchSongsNavVC.pushViewController(sharePostController, animated: true)
    }
    
    //MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        let timestampDate = Date(timeIntervalSince1970: Double(post.timestamp))

        cell.userNameLabel.text = post.name
        cell.trackTitleLabel.text = post.track.title
        cell.trackArtistLabel.text = post.track.artist
        cell.captionLabel.text = post.caption
        cell.timestampLabel.text = timestampDate.timeAgoDisplay()
        cell.userProfilePicImageView.downloadedFrom(link: post.photoUrl)
        cell.trackThumbnailImageView.downloadedFrom(link: post.track.thumbnailURL)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 667
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCreateNewPost") {
            let navVC = segue.destination as! UINavigationController
            let segueVC = navVC.topViewController as! SearchSongsTableViewController
            segueVC.searchSongsDelegate = self
            segueVC.selectLimit = 1
        }
    }
}
