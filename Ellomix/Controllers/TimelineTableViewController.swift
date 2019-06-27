//
//  TimelineTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/2/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, UITabBarControllerDelegate {
    
    private var FirebaseAPI: FirebaseApi!
    var currentUser: EllomixUser!
    var baseDelegate: ContainerViewController!
    var currentPlayingPost: Post!
    var previousTabBarIndex: Int?
    
    let timelineRefreshControl = UIRefreshControl()
    var posts = [Post]()

    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user

        tabBarController?.delegate = self

        // Add Refresh Control to Table View
        timelineRefreshControl.addTarget(self, action: #selector(refreshTimeline(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = timelineRefreshControl
        } else {
            tableView.addSubview(timelineRefreshControl)
        }

        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        retrieveTimeline(refreshing: false)
    }
    
    func retrieveTimeline(refreshing: Bool) {
        FirebaseAPI.getUserTimeline(uid: currentUser.uid, completion: { (posts) in
            self.posts = posts
            self.tableView.reloadData()
            
            if (refreshing) {
                self.timelineRefreshControl.endRefreshing()
            }
        })
    }
    
    @objc func refreshTimeline(_ sender: Any) {
        retrieveTimeline(refreshing: true)
    }

    //MARK: TabBar

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Scroll to top if home tab is tapped while on the timeline
        if (previousTabBarIndex == nil || previousTabBarIndex == tabBarController.selectedIndex) {
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }

        previousTabBarIndex = tabBarController.selectedIndex
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

        cell.userNameButton.setTitle(post.name, for: .normal)
        cell.trackTitleLabel.text = post.track.title
        cell.trackArtistLabel.text = post.track.artist
        cell.captionLabel.text = post.caption
        cell.timestampLabel.text = timestampDate.timeAgoDisplay()
        cell.userProfilePicImageView.downloadedFrom(link: post.photoUrl)
        UIImage.downloadImage(url: post.track.thumbnailURL, completion: { image in
            cell.trackThumbnailButton.setBackgroundImage(image, for: .normal)
        })

        // Update like count
        if (!post.likes.isEmpty) {
            cell.likeCountLabel.text = String(post.likes.count)
        } else {
            cell.likeCountLabel.text = ""
        }

        // Set like button based on if the current user has liked this post
        if (post.likes[currentUser.uid] == true) {
            cell.likeButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
        } else {
            cell.likeButton.setImage(#imageLiteral(resourceName: "heart_outline"), for: .normal)
        }

        // Set play/pause button
        if (currentPlayingPost != nil) {
            if (currentPlayingPost.pid == post.pid) {
                cell.playTrack()
            } else {
                cell.pauseTrack()
            }
        }

        cell.post = post

        // Add action for viewing a user's profile
        cell.userNameButton.addTarget(self, action: #selector(viewUserProfile(sender:)), for: .touchUpInside)

        // Add action for playing tracks
        cell.trackThumbnailButton.addTarget(self, action: #selector(playTrack(sender:)), for: .touchUpInside)
        
        // Add action for liking posts
        cell.likeButton.addTarget(self, action: #selector(likePost(sender:)), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 667
    }
    
    @objc func viewUserProfile(sender: UIButton) {
        if let cell = sender.superview as? PostTableViewCell {
            FirebaseAPI.getUser(uid: cell.post.uid) { (user) -> () in
                self.performSegue(withIdentifier: "toProfile", sender: user)
            }
        }
    }
    
    @objc func playTrack(sender: UIButton) {
        if let cell = sender.superview as? PostTableViewCell {
            if let post = cell.post {
                self.baseDelegate?.playTrack(track: post.track)
                cell.playTrack()
                currentPlayingPost = post
            }
        }
    }
    
    @objc func likePost(sender: UIButton) {
        if let cell = sender.superview as? PostTableViewCell {
            if let post = cell.post {
                if (cell.isLiked()) {
                    cell.likeButton.setImage(#imageLiteral(resourceName: "heart_outline"), for: .normal)
                    post.likes.removeValue(forKey: currentUser.uid)
                    FirebaseAPI.unlikePost(post: post, unliker: currentUser)
                } else {
                    cell.likeButton.setImage(#imageLiteral(resourceName: "heart_filled"), for: .normal)
                    post.likes[currentUser.uid] = true
                    FirebaseAPI.likePost(post: post, liker: currentUser)
                }

                // Update like count
                if (!post.likes.isEmpty) {
                    cell.likeCountLabel.text = String(post.likes.count)
                } else {
                    cell.likeCountLabel.text = ""
                }
            }
        }
    }
    
    //MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            if let user = sender as? EllomixUser {
                let userProfileVC = segue.destination as! ProfileController
                userProfileVC.baseDelegate = baseDelegate
                userProfileVC.currentUser = user
            }
        }
    }
}
