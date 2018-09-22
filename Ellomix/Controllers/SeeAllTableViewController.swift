//
//  SeeAllTableViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 9/6/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SeeAllTableViewController: UITableViewController {

    var sectionForSeeAll: Int = 0
    var seeAllSongs: [AnyObject] = []
    
    var baseDelegate: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seeAllSongs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        
        if (sectionForSeeAll == 1) {
            let scTrack = seeAllSongs[indexPath.row] as? SoundcloudTrack
            cell.trackTitle.text = scTrack?.title
            cell.trackThumbnail.image = scTrack?.thumbnailImage
        } else if (sectionForSeeAll == 2) {
            let ytVideo = seeAllSongs[indexPath.row] as? YouTubeVideo
            cell.trackTitle.text = ytVideo?.videoTitle
            cell.trackThumbnail.image = ytVideo?.videoThumbnailImage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (sectionForSeeAll == 1) {
            let track = seeAllSongs[indexPath.row] as? SoundcloudTrack
            baseDelegate?.playTrack(track: track)
        } else if (sectionForSeeAll == 2) {
            let track = seeAllSongs[indexPath.row] as? YouTubeVideo
            baseDelegate?.playTrack(track: track)
        }
    }

}
