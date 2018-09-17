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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
