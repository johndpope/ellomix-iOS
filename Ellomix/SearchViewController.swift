//
//  SearchViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 4/20/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    let YouTubeAPIKey = "AIzaSyDl9doicP6uc4cEVlRDiM7Ttgy-o7Hal3I"
    var youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search"
    typealias JSONStandard = [String : AnyObject]
    var searchController:UISearchController?
    
    var songs:[AnyObject] = []
    
    override func viewDidLoad() {
        
        
        // Search bar initialization
        searchController = UISearchController(searchResultsController: nil)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.delegate = self
        self.tableView.backgroundView = UIView()
    }
    
    //MARK: TableView functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        if (songs[indexPath.row] is YouTubeVideo) {
            let ytVideo = songs[indexPath.row] as? YouTubeVideo
            cell.songTitle.text = ytVideo?.videoTitle
            cell.artist.text = ytVideo?.videoChannel
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: Searchbar
    func updateSearchResults(for searchController: UISearchController) {
        // In the future, maybe display results as the user types via a background thread.
        if (searchController.searchBar.text != nil && searchController.searchBar.text != "") {
            let searchString = searchController.searchBar.text!
            self.songs = []
            youtubeRequest(query: searchString)
        }
    }
    
    //MARK: YouTube
    func youtubeRequest(query: String) {
        print("---------------REQUESTING FROM YOUTUBE-----------------")
        Alamofire.request(youtubeSearchURL, parameters: ["part":"snippet", "type":"video", "q":query, "key":YouTubeAPIKey]).responseJSON(completionHandler: { response in
            
            //print(response)
            if let JSON = response.result.value as? [String:AnyObject] {
                //print("YouTube JSON data: \(JSON)")
                
                for video in JSON["items"] as! NSArray {
                    print("Video: \(video)")
                    let ytVideo = YouTubeVideo()
                    let videoItem = video as! NSDictionary
                    
                    let id = videoItem["id"] as! NSDictionary
                    ytVideo.videoID = id["videoId"] as? String
                    
                    let snippet = videoItem["snippet"] as! NSDictionary
                    ytVideo.videoTitle = snippet["title"] as? String
                    ytVideo.videoDescription = snippet["description"] as? String
                    ytVideo.videoChannel = snippet["channelTitle"] as? String
                    
                    let thumbnails = snippet["thumbnails"] as! NSDictionary
                    let highRes = thumbnails["high"] as! NSDictionary
                    ytVideo.videoThumbnailURL = highRes["url"] as? String
                    
                    self.songs.append(ytVideo)
                }

                self.tableView.reloadData()
            }
        })
    }
    
}
