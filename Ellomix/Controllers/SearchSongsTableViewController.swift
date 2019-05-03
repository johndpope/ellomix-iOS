//
//  SearchSongsTableViewController.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/9/18.
//  Copyright © 2018 Ellomix. All rights reserved.
//

import UIKit

class SearchSongsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var ytService: YoutubeService!
    private var scService: SoundcloudService!
    private var spService: SpotifyService!
    let searchController = UISearchController(searchResultsController: nil)
    let sections = ["Spotify", "Soundcloud", "YouTube"]
    var songs: [String : [BaseTrack]] = ["Spotify":[], "Soundcloud":[], "YouTube":[]]
    var selected: [String : Dictionary<String, BaseTrack>] = ["Spotify":[:], "Soundcloud":[:], "YouTube":[:]]
    var searchSongsDelegate: SearchSongsDelegate?
    var selectLimit: Int?
    var showCancelButton: Bool = false

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
        
        if (showCancelButton) {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonClicked(_:)))
            navigationItem.leftBarButtonItem = cancelButton
        }
        
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
    
    @objc func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let selectedTracks = Array(selected["Spotify"]!.values) + Array(selected["Soundcloud"]!.values) + Array(selected["YouTube"]!.values)

        searchSongsDelegate?.doneSelecting(selected: selectedTracks)
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
        let type = sections[indexPath.section]
        
        if let track = songs[type]?[indexPath.row] {
            cell.selectionStyle = .none
            cell.trackTitle.text = track.title
            cell.trackThumbnail.image = track.thumbnailImage
            
            if (selected[type]![track.id] != nil) {
                cell.trackTitle.isEnabled = false
                cell.trackThumbnail.alpha = 0.5
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.trackTitle.isEnabled = true
                cell.trackThumbnail.alpha = 1.0
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
        let type = sections[indexPath.section]
        
        if let track = songs[type]?[indexPath.row] {
            if (selected[type]![track.id] != nil) {
                cell.trackTitle.isEnabled = true
                cell.trackThumbnail.alpha = 1.0
                cell.accessoryType = UITableViewCellAccessoryType.none
                selected[type]!.removeValue(forKey: track.id)
            } else {
                cell.trackTitle.isEnabled = false
                cell.trackThumbnail.alpha = 0.5
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                selected[type]![track.id] = track
            }
            
            if (selectLimit != nil && selectLimit! == numberOfSelectedSongs()) {
                let selectedTracks = Array(selected["Spotify"]!.values) + Array(selected["Soundcloud"]!.values) + Array(selected["YouTube"]!.values)

                searchSongsDelegate?.doneSelecting(selected: selectedTracks)
            } else if (numberOfSelectedSongs() > 0) {
                doneButton.isEnabled = true
            } else {
                doneButton.isEnabled = false
            }
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
        var height = 0

        if (section < 3) {
            let type = sections[section]

            if (!songs[type]!.isEmpty) {
                height = 75
            }
        }

        return CGFloat(height)
    }
    
    //MARK: Searchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != nil && searchBar.text != "") {
            let searchString = searchBar.text!
            
            clearSongs()
            spService.search(query: searchString) { (songs) -> () in
                self.songs["Spotify"] = songs
                self.tableView.reloadData()
            }
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
}
