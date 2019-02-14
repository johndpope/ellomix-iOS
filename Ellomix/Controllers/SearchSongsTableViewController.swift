//
//  SearchSongsTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/9/18.
//  Copyright © 2018 Ellomix. All rights reserved.
//

import UIKit

class SearchSongsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    private var ytService: YoutubeService!
    private var scService: SoundcloudService!
    private var spService: SpotifyService!
    let searchController = UISearchController(searchResultsController: nil)
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    var songs: [String:[AnyObject]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    var selected: [String:Dictionary<String, AnyObject>] = ["Spotify":[:], "Soundcloud":[:], "YouTube":[:]]
    var searchSongsDelegate: SearchSongsDelegate?
    var selectLimit: Int?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        ytService = YoutubeService()
        scService = SoundcloudService()
        spService = SpotifyService()
        
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
        doneButton.isEnabled = false
        
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
        
        clearSelected()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        searchSongsDelegate?.doneSelecting(selected: selected)
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
        var type = ""
        var id = ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
        cell.selectionStyle = .none
        
        if (indexPath.section == 1) {
            let scTrack = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack
            cell.trackTitle.text = scTrack?.title
            cell.trackThumbnail.image = scTrack?.thumbnailImage
            id = scTrack!.id!
            type = "Soundcloud"
        } else if (indexPath.section == 2) {
            let ytVideo = songs["YouTube"]?[indexPath.row] as? YouTubeVideo
            cell.trackTitle.text = ytVideo?.videoTitle
            cell.trackThumbnail.image = ytVideo?.videoThumbnailImage
            id = ytVideo!.videoID!
            type = "YouTube"
        }
        
        if (selected[type]![id] != nil) {
            cell.trackTitle.isEnabled = false
            cell.trackThumbnail.alpha = 0.5
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.trackTitle.isEnabled = true
            cell.trackThumbnail.alpha = 1.0
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var type = ""
        var id = ""
        var track: AnyObject?
        let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
        
        if (indexPath.section == 1 && songs["Soundcloud"]!.count > 0) {
            if let scTrack = songs["Soundcloud"]?[indexPath.row] as? SoundcloudTrack {
                type = "Soundcloud"
                id = scTrack.id!
                track = [
                    "artist": scTrack.artist,
                    "title": scTrack.title,
                    "thumbnail_url": scTrack.thumbnailURL?.absoluteString,
                    "id": scTrack.url?.absoluteString,
                    "source": "soundcloud"
                ] as AnyObject
            }
        } else if (indexPath.section == 2 && songs["YouTube"]!.count > 0) {
            if let ytVideo = songs["YouTube"]?[indexPath.row] as? YouTubeVideo {
                type = "YouTube"
                id = ytVideo.videoID!
                track = [
                    "artist": ytVideo.videoChannel,
                    "title": ytVideo.videoTitle,
                    "thumbnail_url": ytVideo.videoThumbnailURL,
                    "id": ytVideo.videoID,
                    "source": "youtube"
                ] as AnyObject
            }
        }
        
        if (selected[type]![id] != nil) {
            cell.trackTitle.isEnabled = true
            cell.trackThumbnail.alpha = 1.0
            cell.accessoryType = UITableViewCellAccessoryType.none
            selected[type]!.removeValue(forKey: id)
        } else {
            cell.trackTitle.isEnabled = false
            cell.trackThumbnail.alpha = 0.5
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            selected[type]![id] = track
        }
        
        if (selectLimit != nil && selectLimit! == numberOfSelectedSongs()) {
            searchSongsDelegate?.doneSelecting(selected: selected)
        } else if (numberOfSelectedSongs() > 0) {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
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
            spService.search(query: searchString)
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
    
    func clearSelected() {
        self.selected["Spotify"] = [:]
        self.selected["Soundcloud"] = [:]
        self.selected["YouTube"] = [:]
    }
    
    func numberOfSelectedSongs() -> Int {
        return selected["Spotify"]!.values.count + selected["Soundcloud"]!.values.count + selected["YouTube"]!.values.count
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSharePost") {
            let segueVC = segue.destination as! SharePostController
            let tracks = selected["Spotify"]!.toArray() + selected["Soundcloud"]!.toArray() + selected["YouTube"]!.toArray()
            
            segueVC.track = tracks.first?.toBaseTrack()
        }
    }
}
