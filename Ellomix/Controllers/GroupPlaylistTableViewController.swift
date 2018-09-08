//
//  GroupPlaylistTableViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/25/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class GroupPlaylistTableViewController: UITableViewController {
    
    private var FirebaseAPI: FirebaseApi!
    private var groupPlaylistRefHandle: DatabaseHandle?
    var group: Group!
    var emptyPlaylistButton = UIButton()
    var emptyPlaylistLabel = UILabel()
    var emptyPlaylistView = UIView()
    var songs = [Dictionary<String, AnyObject>]()
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        
        tableView.register(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (groupPlaylistRefHandle == nil) {
            loadPlaylist()
        }
    }
    
    deinit {
        if let refHandle = groupPlaylistRefHandle {
            FirebaseAPI.getGroupPlaylistsRef().child(group.gid!).removeObserver(withHandle: refHandle)
        }
    }
    
    func loadPlaylist() {
        groupPlaylistRefHandle = FirebaseAPI.getGroupPlaylistsRef().child(group.gid!).observe(.childAdded, with: { (snapshot) in
            var track = snapshot.value as! Dictionary<String, AnyObject>
            track["key"] = snapshot.key as AnyObject
            self.songs.append(track)
            self.songs = self.songs.sorted {($0["order"]! as! Int) < ($1["order"]! as! Int)}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    //MARK: TableView functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "playlistControlsCell") as! GroupPlaylistControlsTableViewCell
            let border = CALayer()
            border.frame = CGRect.init(x: 0, y: cell.frame.height - 1, width: tableView.frame.width, height: 1)
            border.backgroundColor = UIColor.lightGray.cgColor
            cell.layer.addSublayer(border)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell") as! TrackTableViewCell
            let track = songs[indexPath.row - 1]
            cell.trackTitle.text = track["title"] as? String
            let artworkUrl = track["artwork_url"] as? String
            if (artworkUrl == nil) {
                cell.trackThumbnail.image = #imageLiteral(resourceName: "ellomix_logo_bw")
            } else {
                cell.trackThumbnail.downloadedFrom(link: artworkUrl!)
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (songs.count == 0) {
            emptyPlaylistButton = UIButton(frame: CGRect(x: 0, y: 50, width: 150, height: 50))
            emptyPlaylistButton.setTitle("Add Songs", for: .normal)
            emptyPlaylistButton.backgroundColor = UIColor.ellomixBlue()
            emptyPlaylistButton.circular()
            emptyPlaylistButton.center = tableView.center
            emptyPlaylistButton.addTarget(self, action: #selector(addSongsButtonClicked), for: .touchUpInside)
            emptyPlaylistView.addSubview(emptyPlaylistButton)
            
            emptyPlaylistLabel = UILabel(frame: CGRect(x: 0, y: emptyPlaylistButton.frame.origin.y - 100, width: tableView.bounds.size.width, height: 100))
            emptyPlaylistLabel.textAlignment = .center
            emptyPlaylistLabel.font = UIFont.boldSystemFont(ofSize: 16)
            emptyPlaylistLabel.text = "Put the group on to some new songs."
            emptyPlaylistView.addSubview(emptyPlaylistLabel)
            
            tableView.backgroundView = emptyPlaylistView
            
            return 0
        } else {
            tableView.backgroundView = nil
            
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
           return 80
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let track = songs.remove(at: indexPath.row - 1)
            for i in 0..<songs.count {
                songs[i]["order"] = i as AnyObject
            }
            FirebaseAPI.removeFromGroupPlaylist(group: group, key: track["key"] as! String, data: songs)
            tableView.reloadData()
        }
    }

    func addSongsToPlaylist(selectedSongs: [String:Dictionary<String, AnyObject>]) {
        var tracks = selectedSongs["Spotify"]!.toArray() + selectedSongs["Soundcloud"]!.toArray() + selectedSongs["YouTube"]!.toArray()
        var order = songs.count
        for i in 0..<tracks.count {
            tracks[i]["order"] = order as AnyObject
            order += 1
        }
        FirebaseAPI.addToGroupPlaylist(group: group, data: tracks)
    }
    
    func addSongsButtonClicked() {
        performSegue(withIdentifier: "toAddSongsToPlaylist", sender: nil)
    }
    
    @IBAction func barAddSongsButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toAddSongsToPlaylist", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddSongsToPlaylist") {
            let navVC = segue.destination as! UINavigationController
            let segueVC = navVC.topViewController as! SearchSongsTableViewController
            segueVC.delegate = self
        }
    }
}
