//
//  SearchViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 4/20/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Alamofire
import Soundcloud
import Firebase

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let YouTubeAPIKey = "AIzaSyDl9doicP6uc4cEVlRDiM7Ttgy-o7Hal3I"
    var youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search"
    typealias JSONStandard = [String : AnyObject]
    var searchController:UISearchController?
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    let searchFilters = ["Music", "People"]
    var scope = "Music"
    
    var songs:[String:[AnyObject]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    
    private var FirebaseAPI: FirebaseApi!
    var allUsers = [Dictionary<String, AnyObject>?]()
    var filteredUsers = [Dictionary<String, AnyObject>?]()

    var baseDelegate:ContainerViewController?
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        self.definesPresentationContext = true
        
        // Search bar initialization
        searchController = UISearchController(searchResultsController: nil)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchBar.scopeButtonTitles = searchFilters
        searchController?.searchBar.delegate = self
        self.tableView.backgroundView = UIView()

        retrieveUsers()
    }

    func retrieveUsers() {
        FirebaseAPI.getUsersRef().queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            self.allUsers.append(snapshot.value as? Dictionary)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: TableView functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (scope == "Music") {
            if (section == 0) {
                return songs["Spotify"]!.count
            } else if (section == 1) {
                return songs["Soundcloud"]!.count
            } else {
                return songs["YouTube"]!.count
            }
        }

        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell

        if (scope == "Music") {
            if (indexPath.section == 1 && indexPath.row < songs["Soundcloud"]!.count) {
                let scTrack = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
                cell.songTitle.text = scTrack?.title
                cell.artist.text = scTrack?.artist
                cell.serviceIcon.image = #imageLiteral(resourceName: "soundcloud")
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: (scTrack?.thumbnailURL)!)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        cell.thumbnail.image = image
                        scTrack?.thumbnailImage = image
                    }
                }
            } else if (indexPath.section == 2 && indexPath.row < songs["YouTube"]!.count) {
                let ytVideo = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
                cell.songTitle.text = ytVideo?.videoTitle
                cell.artist.text = ytVideo?.videoChannel
                cell.serviceIcon.image = #imageLiteral(resourceName: "youtube")
                
                let url = URL(string: (ytVideo?.videoThumbnailURL)!)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        cell.thumbnail.image = UIImage(data: data!)
                    }
                }
            }
        } else {
            let user = filteredUsers[indexPath.row]
            cell.songTitle.text = user!["name"] as? String
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let track = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
            baseDelegate?.activatePlaybar(track: track)
        } else if (indexPath.section == 2) {
            let track = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
            baseDelegate?.activatePlaybar(track: track)
        }
        
        // Pop UISearchController
        // self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (scope == "Music") {
            return sections.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (scope == "Music") {
            return sections[section]
        }
        
        return nil
    }
    
    //MARK: Searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != nil && searchBar.text != "") {
            let searchString = searchBar.text!
            
            if (scope == "Music") {
                clearSongs()
                soundcloudRequest(query: searchString)
                youtubeRequest(query: searchString)
            } else {
                
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if (scope == "People") {
            filterUsers(searchText: searchController.searchBar.text!)
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scope = searchFilters[selectedScope]
        self.tableView.reloadData()
    }
    
    //MARK: Soundcloud
    func soundcloudRequest(query: String) {
        Track.search(queries: [.queryString(query)]) { response in
            print("--------------REQUESTING FROM SOUNDCLOUD---------------")
            //print("Soundcloud response: \(response.response.result)")
            if let tracks = response.response.result {
                
                for track in tracks {
                    let scTrack = SoundcloudTrack()
                    
                    scTrack.title = track.title
                    scTrack.artist = track.createdBy.username
                    scTrack.url = track.streamURL
                    scTrack.thumbnailURL = track.artworkImageURL.highURL
                    
                    self.songs["Soundcloud"]?.append(scTrack)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: YouTube
    func youtubeRequest(query: String) {
        Alamofire.request(youtubeSearchURL, parameters: ["part":"snippet", "type":"video", "q":query, "maxResults":"50", "key":YouTubeAPIKey]).responseJSON(completionHandler: { response in
            
            print("---------------REQUESTING FROM YOUTUBE-----------------")
            //print(response)
            if let JSON = response.result.value as? [String:AnyObject] {
                //print("YouTube JSON data: \(JSON)")
                
                for video in JSON["items"] as! NSArray {
                    //print("Video: \(video)")
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
                    
                    
                    self.songs["YouTube"]?.append(ytVideo)
                }

                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: Helpers
    
    func clearSongs() {
        self.songs["Spotify"] = []
        self.songs["Soundcloud"] = []
        self.songs["YouTube"] = []
    }
    
    func filterUsers(searchText: String) {
        filteredUsers = allUsers.filter{ user in
            let name = user!["name"] as? String
            return (name?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
}
