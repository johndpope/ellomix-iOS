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

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SharePostDelegate {
    
    let YouTubeAPIKey = "AIzaSyDl9doicP6uc4cEVlRDiM7Ttgy-o7Hal3I"
    var youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search"
    var spotifySearchURL = "https://api.spotify.com/v1/search"
    var searchController: UISearchController?
    var selectUsersOrGroupsControllerNavController: UINavigationController!
    var sharePostNavController: UINavigationController!
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    let searchFilters = ["Music", "People"]
    var scope = "Music"
    var isSearchSPDone = false // Spotify search flag
    var isSearchSCDone = false // Soundcloud search flag
    var isSearchYTDone = false // Youtube search flag
    var isSearchUserDone = false // user filter flag
    
    let searchLimit = 3
    
    var songs: [String:[BaseTrack]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    
    var sectionForSeeAll: Int = 0
    
    private var FirebaseAPI: FirebaseApi!
    var allUsers = [Dictionary<String, AnyObject>?]()
    var filteredUsers = [Dictionary<String, AnyObject>?]()

    var baseDelegate: ContainerViewController?
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        definesPresentationContext = true
        
        // Search bar initialization
        searchController = UISearchController(searchResultsController: nil)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchResultsUpdater = self
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchBar.scopeButtonTitles = searchFilters
        searchController?.searchBar.delegate = self
        tableView.backgroundView = UIView()
        
        let selectUsersOrGroupsStoryboard = UIStoryboard(name: "SelectUsersOrGroups", bundle: nil)
        let sharePostStoryboard = UIStoryboard(name: "SharePost", bundle: nil)

        selectUsersOrGroupsControllerNavController = selectUsersOrGroupsStoryboard.instantiateViewController(withIdentifier: "selectUsersOrGroupsNavController") as? UINavigationController
        sharePostNavController = sharePostStoryboard.instantiateViewController(withIdentifier: "sharePostNavController") as? UINavigationController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.allUsers.removeAll()
        retrieveUsers()
    }
    
    override func viewDidLayoutSubviews() {
        searchController?.searchBar.sizeToFit()
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
        //Check if download is complete and check if the result is zero (aka create a cell with "No search results." label)
        if (scope == "Music") {
            if (section == 0) {
                let spotifySongCount = songs["Spotify"]!.count
                return spotifySongCount > searchLimit ? searchLimit : spotifySongCount
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
            
            if (indexPath.section == 0) {
                let spCount = (songs["Spotify"]?.count)!
                if isSearchSPDone && spCount == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
                } else {
                    if let track = songs["Spotify"]?[indexPath.row] {
                        cell.songTitle.text = track.title
                        cell.artist.text = track.artist
                        // cell.serviceIcon.image = #imageLiteral(resourceName: "soundcloud")
                        cell.thumbnail.image = track.thumbnailImage
                        cell.track = track
                    }
                }
            } else if (indexPath.section == 1) {
                let scCount = (songs["Soundcloud"]?.count)!
                if isSearchSCDone && scCount == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
                } else {
                    if let track = songs["Soundcloud"]?[indexPath.row] {
                        cell.songTitle.text = track.title
                        cell.artist.text = track.artist
                        cell.serviceIcon.image = #imageLiteral(resourceName: "soundcloud")
                        cell.thumbnail.image = track.thumbnailImage
                        cell.track = track
                    }
                }
            } else if (indexPath.section == 2) {
                let ytCount = songs["YouTube"]!.count
                if isSearchYTDone && ytCount == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
                } else {
                    if let track = songs["YouTube"]?[indexPath.row] {
                        cell.songTitle.text = track.title
                        cell.artist.text = track.artist
                        cell.serviceIcon.image = #imageLiteral(resourceName: "youtube")
                        cell.thumbnail.image = track.thumbnailImage
                        cell.track = track
                    }
                }
            }
            cell.optionsButton.addTarget(self, action: #selector(showOptionsMenu(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            let userCount = filteredUsers.count
            if isSearchUserDone && userCount == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "noSearchFoundCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchPeopleCell", for: indexPath) as! SearchTableViewPeopleCell
            let user = filteredUsers[indexPath.row]
            cell.nameLabel.text = user!["name"] as? String
            cell.profilePicImageView.downloadedFrom(link: user!["photo_url"] as? String)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (scope == "Music") {
            if (indexPath.section == 0) {
                if songs["Spotify"]!.count > 0 {
                    if let track = songs["Spotify"]?[indexPath.row] {
                        baseDelegate?.playTrack(track: track)
                    }
                }
            }
            if (indexPath.section == 1) {
                if songs["Soundcloud"]!.count > 0 {
                    if let track = songs["Soundcloud"]?[indexPath.row] {
                        baseDelegate?.playTrack(track: track)
                    }
                }
            } else if (indexPath.section == 2) {
                if songs["YouTube"]!.count > 0 {
                    if let track = songs["YouTube"]?[indexPath.row] {
                        baseDelegate?.playTrack(track: track)
                    }
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
                ellomixUser.profilePicture.downloadedFrom(link: photoURL)
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
            headerCell.buttonAction = { sender in
                if (headerCell.sectionTitleLabel.text == "Spotify") {
                    self.sectionForSeeAll = 0
                    self.performSegue(withIdentifier: "toSeeAll", sender: nil)
                }
                if (headerCell.sectionTitleLabel.text == "Soundcloud") {
                    self.sectionForSeeAll = 1
                    self.performSegue(withIdentifier: "toSeeAll", sender: nil)
                }
                if (headerCell.sectionTitleLabel.text == "YouTube") {
                    self.sectionForSeeAll = 2
                    self.performSegue(withIdentifier: "toSeeAll", sender: nil)
                }
            }
        } else {
            headerCell.sectionTitleLabel.text = "People"
        }
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (scope == "Music") {
            switch section {
            case 0:
                if isSearchSPDone  {
                    return 75
                }
                
                return 0
            case 1:
                if isSearchSCDone  {
                    return 75
                }

                return 0
            case 2:
                if isSearchYTDone {
                    return 75
                }

                return 0
            default:
                return 0
            }
        } else {
            if isSearchUserDone {
                return 75
            }

            return 0
        }
    }
    
    func showOptionsMenu(sender: UIButton) {
        var actions = [UIAlertAction]()

        let postAction = UIAlertAction(title: "Create Post", style: .default) { _ in
            if let cell = sender.superview?.superview as? SearchTableViewMusicCell {
                let sharePostVC = self.sharePostNavController.topViewController as! SharePostController

                sharePostVC.track = cell.track
                sharePostVC.showCancelButton = true
                sharePostVC.sharePostDelegate = self
                self.present(self.sharePostNavController, animated: true, completion: nil)
            }
        }
        let shareAction = UIAlertAction(title: "Send to Friends", style: .default) { _ in
            let selectUsersOrGroupsVC = self.selectUsersOrGroupsControllerNavController.topViewController as! SelectUsersOrGroupsController
            if let cell = sender.superview?.superview as? SearchTableViewMusicCell {
                selectUsersOrGroupsVC.currentTrack = cell.track
                self.present(self.selectUsersOrGroupsControllerNavController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actions.append(postAction)
        actions.append(shareAction)
        actions.append(cancelAction)
        EllomixAlertController.showActionSheet(viewController: self, actions: actions)
    }
    
    //MARK: Searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != nil && searchBar.text != "") {
            let searchString = searchBar.text!
            
            if (scope == "Music") {
                clearSongs()
                soundcloudRequest(query: searchString)
                youtubeRequest(query: searchString)
                spotifyRequest(query: searchString)
            } else {
                
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if (scope == "People" && !(searchController.searchBar.text!.isEmpty)) {
            filterUsers(searchText: searchController.searchBar.text!)
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        scope = searchFilters[selectedScope]
        self.tableView.reloadData()
    }
    
    //MARK: Spotify
    func spotifyRequest(query: String) {
        
        isSearchSPDone = false
        let auth: SPTAuth = SPTAuth.defaultInstance()
        
        if auth.session != nil {
            let token = auth.session.accessToken
            
            SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: token) { (error, result) in
                print("--------------REQUESTING FROM SPOTIFY---------------")
                
                if let listPage = result as? SPTListPage,
                    let items = listPage.items as? [SPTPartialTrack] {
                    for item in items {
                        let spTrack = SpotifyTrack()
                        
                        spTrack.title = item.name
                        
                        let artist = item.artists.first as? SPTPartialArtist
                        spTrack.artist = artist?.name
                        spTrack.url = item.previewURL
                        spTrack.id = item.identifier
                        spTrack.source = "spotify"
                        
                        let thumbnailURL = item.album.largestCover.imageURL
                        
                        if (thumbnailURL != nil) {
                            spTrack.thumbnailURL = thumbnailURL?.absoluteString
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: thumbnailURL!) {
                                    DispatchQueue.main.async {
                                        spTrack.thumbnailImage = UIImage(data: data)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                        
                        self.songs["Spotify"]?.append(spTrack)
                    }
                    
                    self.isSearchSPDone = true
                    self.tableView.reloadData()
                }
            }
        } else {
            print("User is not signed into Spotify.")
        }
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
                    scTrack.source = "soundcloud"
                    
                    let thumbnailURL = track.artworkImageURL.highURL
    
                    if (thumbnailURL != nil) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: thumbnailURL!) {
                                DispatchQueue.main.async {
                                    scTrack.thumbnailImage = UIImage(data: data)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } else {
                        scTrack.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
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
                    ytVideo.id = id["videoId"] as? String
                    
                    let snippet = videoItem["snippet"] as! NSDictionary
                    ytVideo.title = snippet["title"] as? String
                    ytVideo.videoDescription = snippet["description"] as? String
                    ytVideo.artist = snippet["channelTitle"] as? String
                    ytVideo.source = "youtube"
                    
                    let thumbnails = snippet["thumbnails"] as! NSDictionary
                    let highRes = thumbnails["high"] as! NSDictionary
                    ytVideo.thumbnailURL = highRes["url"] as? String
                    if (ytVideo.thumbnailURL != nil) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: URL(string: ytVideo.thumbnailURL!)!) {
                                DispatchQueue.main.async {
                                    ytVideo.thumbnailImage = UIImage(data: data)
                                    self.tableView.reloadData()
                                }
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
    
    //MARK: SharePostDelegate
    func didSharePost(sharePostVC: SharePostController) {
        sharePostVC.dismiss(animated: true, completion: nil)
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
        if (segue.identifier == "toSeeAll") {
            let destinationVC = segue.destination as! SeeAllTableViewController

            destinationVC.baseDelegate = baseDelegate
            if (sectionForSeeAll == 0) {
                destinationVC.seeAllSongs = songs["Spotify"]!
            }
            if (sectionForSeeAll == 1) {
                destinationVC.seeAllSongs = songs["Soundcloud"]!
            }
            if (sectionForSeeAll == 2) {
                destinationVC.seeAllSongs = songs["YouTube"]!
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
