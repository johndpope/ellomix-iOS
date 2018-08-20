//
//  SearchSongsTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/9/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class SearchSongsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    private var ytService: YoutubeService!
    private var scService: SoundcloudService!
    let searchController = UISearchController(searchResultsController: nil)
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    var songs:[String:[AnyObject]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    
    override func viewDidLoad() {
        ytService = YoutubeService()
        scService = SoundcloudService()
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Songs"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
        
        tableView.register(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        tableView.register(UINib(nibName: "SectionLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        
        // Workaround for disabling sticky header cells
        let dummyViewHeight = CGFloat(70)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    //MARK: TableView functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            let spotifySongCount = songs["Spotify"]!.count
            return spotifySongCount
        } else if (section == 1) {
            let soundcloudSongCount = songs["Soundcloud"]!.count
            return soundcloudSongCount
        } else {
            let youtubeSongCount = songs["YouTube"]!.count
            return youtubeSongCount
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        
        if (indexPath.section == 1) {
            let scTrack = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
            cell.trackTitle.text = scTrack?.title
            cell.trackThumbnail.image = scTrack?.thumbnailImage
        } else if (indexPath.section == 2) {
            let ytVideo = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
            cell.trackTitle.text = ytVideo?.videoTitle
            cell.trackThumbnail.image = ytVideo?.videoThumbnailImage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! SectionLabelTableViewCell
        headerCell.label.text = sections[section]
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            if (!songs["Soundcloud"]!.isEmpty) {
                return 75
            }
            
            return 0
        case 2:
            if (!songs["YouTube"]!.isEmpty) {
                return 75
            }
            
            return 0
        default:
            return 0
        }
    }
    
    //MARK: Searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != nil && searchBar.text != "") {
            let searchString = searchBar.text!
            
            clearSongs()
            scService.search(query: searchString) { (songs) -> () in
                self.songs["Soundcloud"] = songs
                self.tableView.reloadData()
            }
            ytService.search(query: searchString) { (videos) -> () in
                self.songs["YouTube"] = videos
                self.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Silence is golden...
    }
    
    //MARK: Helpers
    func clearSongs() {
        self.songs["Spotify"] = []
        self.songs["Soundcloud"] = []
        self.songs["YouTube"] = []
    }
}
