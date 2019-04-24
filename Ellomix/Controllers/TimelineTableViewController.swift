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
    var currentTrackCell: PostTableViewCell!
    
    let timelineRefreshControl = UIRefreshControl()
    var posts = [Post]()

    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        currentUser = Global.sharedGlobal.user

        // Add Refresh Control to Table View
        timelineRefreshControl.addTarget(self, action: #selector(refreshTimeline(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = timelineRefreshControl
        } else {
            tableView.addSubview(timelineRefreshControl)
        }

        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")

        let sharePostStoryboard = UIStoryboard(name: "SharePost", bundle: nil)
        sharePostController = sharePostStoryboard.instantiateViewController(withIdentifier: "sharePostController") as? SharePostController
        
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
    
    func refreshTimeline(_ sender: Any) {
        retrieveTimeline(refreshing: true)
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
        UIImage.downloadImage(url: post.track.thumbnailURL, completion: { image in
            cell.trackThumbnailButton.setBackgroundImage(image, for: .normal)
        })
        
        // Add action for playing tracks
        cell.track = post.track
        cell.trackThumbnailButton.addTarget(self, action: #selector(playTrack(sender:)), for: .touchUpInside)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 667
    }
    
    func playTrack(sender: UIButton) {
        if let cell = sender.superview as? PostTableViewCell {
            if let baseTrack = cell.track {
                self.baseDelegate?.playTrack(track: baseTrack)
                
                if (currentTrackCell != cell) {
                    // A different track on the timeline was chosen
                    cell.playTrack()

                    // If there is current track cell playing, pause it
                    if (currentTrackCell != nil) {
                        currentTrackCell.pauseTrack()
                    }

                    currentTrackCell = cell
                }
            }
        }
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
