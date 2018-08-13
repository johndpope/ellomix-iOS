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
    var spotifySearchURL = "https://api.spotify.com/v1/search"
    typealias JSONStandard = [String : AnyObject]
    var searchController:UISearchController?
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    let searchFilters = ["Music", "People"]
    var scope = "Music"
    var isSearchSPDone = false // Spotify search flag
    var isSearchSCDone = false // Soundcloud search flag
    var isSearchYTDone = false // Youtube search flag
    var isSearchUserDone = false //user filter flag
    
    let searchLimit = 3
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.allUsers.removeAll()
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
        //Check if download is complete and check if the result is zero (aka create a cell with "No search results." label
        if (scope == "Music") {
            if (section == 0) {
                let spotifySongCount = songs["Spotify"]!.count
                return spotifySongCount
            } else if (section == 1) {
                let soundcloudSongCount = songs["Soundcloud"]!.count
                if isSearchSCDone {
                    if soundcloudSongCount == 0 {
                        return 1
                    }
                    return soundcloudSongCount > searchLimit ? searchLimit : soundcloudSongCount
                }
                return soundcloudSongCount
                
            } else {
                let youtubeSongCount = songs["YouTube"]!.count
                if isSearchYTDone {
                    if youtubeSongCount == 0 {
                        return 1
                    }
                    return youtubeSongCount > searchLimit ? searchLimit : youtubeSongCount
                }
                return youtubeSongCount
            }
        }
        
        return (isSearchUserDone && filteredUsers.count == 0) ? 1 : filteredUsers.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (scope == "Music") {
            // Check which section to add to and then check if the search is done and if there are any results
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchMusicCell") as! SearchTableViewMusicCell
            
            if indexPath.section == 1 {
                let scCount = (songs["Soundcloud"]?.count)!
                if isSearchSCDone && scCount == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
                }
//                else if indexPath.row < scCount {
                else {
                    let scTrack = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
                    cell.songTitle.text = scTrack?.title
                    cell.artist.text = scTrack?.artist
                    cell.serviceIcon.image = #imageLiteral(resourceName: "soundcloud")
                    cell.thumbnail.image = scTrack?.thumbnailImage
                    
                }
            }
            else if indexPath.section == 2 {
                let ytCount = songs["YouTube"]!.count
                if isSearchYTDone && ytCount == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
                }
//                else if indexPath.row < ytCount
                else {
                    let ytVideo = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
                    cell.songTitle.text = ytVideo?.videoTitle
                    cell.artist.text = ytVideo?.videoChannel
                    cell.serviceIcon.image = #imageLiteral(resourceName: "youtube")
                    cell.thumbnail.image = ytVideo?.videoThumbnailImage
                    
                }
            }
            return cell
        }
        else {
            let userCount = filteredUsers.count
            if isSearchUserDone && userCount == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchPeopleCell", for: indexPath) as! SearchTableViewPeopleCell
            let user = filteredUsers[indexPath.row]
            cell.nameLabel.text = user!["name"] as? String
            if (user!["photo_url"] as? String == "" || user!["photo_url"] == nil) {
                cell.profilePicImageView.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            } else {
                let url = user!["photo_url"]! as? String
                cell.profilePicImageView.downloadedFrom(link: url!)
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (scope == "Music") {
            if (indexPath.section == 1) {
                if songs["Soundcloud"]!.count > 0 {
                    let track = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
                    baseDelegate?.activatePlaybar(track: track)
                }
            } else if (indexPath.section == 2) {
                if songs["YouTube"]!.count > 0 {
                    let track = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
                    baseDelegate?.activatePlaybar(track: track)
                }
            }
        } else {
            if filteredUsers.count > 0 {
                let user = filteredUsers[indexPath.row]
                let uid = user!["uid"] as? String
                let name = user!["name"] as? String
                let photoURL = user!["photo_url"] as? String
                let followingCount = user!["following_count"] as? Int
                let followersCount = user!["followers_count"] as? Int
                let ellomixUser = EllomixUser(uid: uid!)
                ellomixUser.setName(name: name!)
                ellomixUser.setProfilePicLink(link: photoURL!)
                ellomixUser.setFollowingCount(count: followingCount)
                ellomixUser.setFollowersCount(count: followersCount)
                ellomixUser.profilePicture.downloadedFrom(link: photoURL!)
                performSegue(withIdentifier: "toProfile", sender: ellomixUser)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (scope == "Music") {
            return sections.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "searchHeaderCell") as! SearchHeaderCell
        
        if (scope == "Music") {
            headerCell.sectionTitleLabel.text = sections[section]
        } else {
            headerCell.sectionTitleLabel.text = "People"
        }
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (scope == "Music") {
            switch section {
            case 0:
                return 0
            case 1:
                if isSearchSCDone  {
                    return 75
                }
//                else if !songs["Soundcloud"]!.isEmpty {
//                    return 75
//                }

                return 0
            case 2:
                if isSearchYTDone {
                    return 75
                }
//                if (!songs["YouTube"]!.isEmpty) {
//                    return 75
//                }

                return 0
            default:
                return 0
            }
        } else {
            if isSearchUserDone {
                return 75
            }
//            if (!filteredUsers.isEmpty) {
//                return 75
//            }
//
            return 0
        }
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
        
        isSearchSCDone = false
        Track.search(queries: [.queryString(query)]) { response in
            print("--------------REQUESTING FROM SOUNDCLOUD---------------")
            //print("Soundcloud response: \(response.response.result)")
            if let tracks = response.response.result {
                
                for track in tracks {
                    let scTrack = SoundcloudTrack()
                    
                    scTrack.title = track.title
                    scTrack.artist = track.createdBy.username
                    scTrack.url = track.streamURL
                    scTrack.id = String(track.identifier)
                    if (track.artworkImageURL.highURL != nil) {
                        scTrack.thumbnailURL = track.artworkImageURL.highURL
                    } else {
                        scTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
                    }
                    
                    if (scTrack.thumbnailURL != nil) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: scTrack.thumbnailURL!) {
                                DispatchQueue.main.async {
                                    scTrack.thumbnailImage = UIImage(data: data)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    
                    self.songs["Soundcloud"]?.append(scTrack)
                }
                self.isSearchSCDone = true
                
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: YouTube
    func youtubeRequest(query: String) {
        
        isSearchYTDone = false
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
                    DispatchQueue.global().async {
                        if let ytVideoThumbnail = ytVideo.videoThumbnailURL, let data = try? Data(contentsOf: URL(string: ytVideoThumbnail)!) {
                            DispatchQueue.main.async {
                                ytVideo.videoThumbnailImage = UIImage(data: data)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    self.songs["YouTube"]?.append(ytVideo)
                }
                self.isSearchYTDone = true
                

                self.tableView.reloadData()
            }
        })
    }
    
    //MARK: Spotify Data:
    func parseSpotify(JSONData : Data) {
        do {
            var readableJSON =
                try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count {
                        let spTrack = SpotifyTrack()
                        let item = items[i]
                        spTrack.trackTitle = item["name"] as? String
                        spTrack.trackURI = item["uri"] as? String
                        spTrack.trackPreviewURL = item["preview_url"] as? String
                        if let artists = item["artists"] as? [JSONStandard] {
                            if let firstArtistData = artists[0] as? JSONStandard {
                                spTrack.trackArtist = firstArtistData["name"] as! String
                            }
                        }
                        if let album = item["album"] as? JSONStandard {
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                let imageString = imageData["url"] as! String
                                spTrack.trackThumbnailURL = imageString
                                let mainImageURL = URL(string:imageString)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData as! Data)
                                self.songs["Spotify"]?.append(spTrack)
                            }
                        }
                    }
                }
            }
            print(readableJSON)
        }
        catch {
            print(error)
        }
    }
    
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toProfile") {
            if let user = sender as? EllomixUser {
                let userProfileVC = segue.destination as! ProfileController
                userProfileVC.currentUser = user
            }
        }
    }
    
    //MARK: Helpers
    func clearSongs() {
        self.songs["Spotify"] = []
        self.songs["Soundcloud"] = []
        self.songs["YouTube"] = []
    }
    
    func filterUsers(searchText: String) {
        isSearchUserDone = false
        filteredUsers = allUsers.filter{ user in
            if let name = user!["name"] as? String {
                return name.lowercased().contains(searchText.lowercased())
            }
            
            return false
        }
        isSearchUserDone = true
    }
    
}
