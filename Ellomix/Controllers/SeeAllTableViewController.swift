//
//  SeeAllTableViewController.swift
//  Ellomix
//
//  Created by Steven  Villarreal on 9/6/18.
//  Copyright © 2018 Ellomix. All rights reserved.
//

import UIKit

class SeeAllTableViewController: UITableViewController {

    var sectionForSeeAll: Int = 0
    var seeAllSongs: [BaseTrack] = []
    private var queue = [BaseTrack]()
    
    var baseDelegate: ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...(seeAllSongs.count - 1) {
            let track = seeAllSongs[i]

            queue.append(track)
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
        let track = seeAllSongs[indexPath.row]
        
        cell.trackTitle.text = track.title
        cell.trackThumbnail.image = track.thumbnailImage

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baseDelegate?.playQueue(queue: queue, startingIndex: indexPath.row)
    }

}
