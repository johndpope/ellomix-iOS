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
    private var queue = [Dictionary<String, AnyObject>]()
    
    var baseDelegate: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var track: AnyObject?
        for i in 0...(seeAllSongs.count - 1) {
            if let scTrack = seeAllSongs[i] as? SoundcloudTrack {
                track = [
                    "artist": scTrack.artist,
                    "title": scTrack.title,
                    "artwork_url": scTrack.thumbnailURL?.absoluteString,
                    "stream_uri": scTrack.url?.absoluteString,
                    "source": "soundcloud"
                    ] as AnyObject
            }
            if let ytVideo = seeAllSongs[i] as? YouTubeVideo {
                track = [
                    "artist": ytVideo.videoChannel,
                    "title": ytVideo.videoTitle,
                    "artwork_url": ytVideo.videoThumbnailURL,
                    "stream_uri": ytVideo.videoID,
                    "source": "youtube"
                    ] as AnyObject
            }
            queue.append(track as! [String : AnyObject])
        }
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
        baseDelegate?.playQueue(queue: queue, startingIndex: indexPath.row)
    }

}
