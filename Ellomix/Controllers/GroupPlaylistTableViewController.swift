//
//  GroupPlaylistTableViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/25/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import Firebase

class GroupPlaylistTableViewController: UITableViewController, SearchSongsDelegate {
    
    private var FirebaseAPI: FirebaseApi!
    private var groupPlaylistRefHandle: DatabaseHandle?
    var baseDelegate: ContainerViewController!
    var group: Group!
    var cellSnapShot: UIView?
    var initialIndexPath: IndexPath?
    var hideCellAllowed: Bool!
    var emptyPlaylistButton = UIButton()
    var emptyPlaylistLabel = UILabel()
    var emptyPlaylistView = UIView()
    var songs = [BaseTrack]()
    
    override func viewDidLoad() {
        FirebaseAPI = FirebaseApi()
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        tableView.addGestureRecognizer(longpress)
        
        tableView.register(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseDelegate.playBarViewBottomConstraint.constant = -(self.tabBarController?.tabBar.frame.height)!
        if (groupPlaylistRefHandle == nil) {
            if let gid = group.gid {
                FirebaseAPI.loadPlaylist(gid: gid, completion: { (songs) in
                    self.songs = songs
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseAPI.orderGroupPlaylist(group: group, data: songs)
        baseDelegate.playBarViewBottomConstraint.constant = 0
    }
    
    deinit {
        if let refHandle = groupPlaylistRefHandle {
            FirebaseAPI.getGroupPlaylistsRef().child(group.gid!).removeObserver(withHandle: refHandle)
        }
    }
    
    /*
    func loadPlaylist() {
        groupPlaylistRefHandle = FirebaseAPI.getGroupPlaylistsRef().child(group.gid!).observe(.childAdded, with: { (snapshot) in
            if let trackDict = snapshot.value as? Dictionary<String, AnyObject> {
                let track = trackDict.toBaseTrack()

                track.sid = snapshot.key
                self.songs.append(track)
                self.songs = self.songs.sorted {($0.order)! < ($1.order)!}
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    */
    
    @IBAction func playButtonClicked(_ sender: Any) {
        baseDelegate.playQueue(queue: songs, startingIndex: 0)
    }
    
    @IBAction func shuffleButtonClicked(_ sender: Any) {
        if let shuffledTracks = songs.shuffle() as? [BaseTrack] {
            baseDelegate.playQueue(queue: shuffledTracks, startingIndex: 0)
        }
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
            cell.trackTitle.text = track.title
            cell.trackThumbnail.downloadedFrom(link: track.thumbnailURL)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row > 0) {
            baseDelegate.playQueue(queue: songs, startingIndex: indexPath.row - 1)
        }
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
                songs[i].order = i
            }
            
            if let sid = track.sid {
                FirebaseAPI.removeFromGroupPlaylist(group: group, key: sid, data: songs)
                tableView.reloadData()
            }
        }
    }
    
    //MARK: LongPress functions
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longpress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longpress.state
        let locationInView = longpress.location(in: self.tableView)
        var indexPath = tableView.indexPathForRow(at: locationInView)
        hideCellAllowed = true
        
        switch state {
        case .began:
            if (indexPath != nil) {
                initialIndexPath = indexPath
                let cell = self.tableView.cellForRow(at: indexPath!) as! TrackTableViewCell
                cellSnapShot = snapshopOfCell(inputView: cell)
                var center = cell.center
                cellSnapShot?.center = center
                cellSnapShot?.alpha = 0.0
                tableView.addSubview(cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    self.cellSnapShot?.center = center
                    self.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    self.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if (finished && self.hideCellAllowed) {
                        cell.isHidden = true
                    }
                })
            }
        case .changed:
            var center = cellSnapShot?.center
            center?.y = locationInView.y
            cellSnapShot?.center = center!
            if ((indexPath != nil) && (indexPath != initialIndexPath) && (indexPath!.row > 0)) {
                let newRow = (indexPath?.row)! - 1
                let initialRow = (initialIndexPath?.row)! - 1
                songs.swapAt(newRow, initialRow)
                let oldOrder = songs[newRow].order
                songs[newRow].order = songs[initialRow].order
                songs[initialRow].order = oldOrder
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                initialIndexPath = indexPath

                // Handle autoscroll
                if ((indexPath == tableView.indexPathsForVisibleRows?.last) && (indexPath!.row + 1 <= songs.count)) {
                    var nextIndexPath = indexPath!
                    nextIndexPath.row = nextIndexPath.row + 1
                    tableView.scrollToRow(at: nextIndexPath, at: .bottom, animated: true)
                } else if (((tableView.indexPathsForVisibleRows?.first?.row)! > 0) && (indexPath!.row - 1 == (tableView.indexPathsForVisibleRows?.first?.row)!)) {
                    var prevIndexPath = indexPath!
                    prevIndexPath.row = prevIndexPath.row - 1
                    tableView.scrollToRow(at: prevIndexPath, at: .top, animated: true)
                }
            }
        default:
            let cell = tableView.cellForRow(at: initialIndexPath!) as! TrackTableViewCell
            hideCellAllowed = false
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                self.cellSnapShot?.center = cell.center
                self.cellSnapShot?.transform = .identity
                self.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if (finished) {
                    self.initialIndexPath = nil
                    self.cellSnapShot?.removeFromSuperview()
                    self.cellSnapShot = nil
                }
            })
        }
        
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4

        return cellSnapshot
    }

//    func addSongsToPlaylist(tracks: [BaseTrack]) {
//        var order = songs.count
//
//        for i in 0..<tracks.count {
//            tracks[i].order = order
//            order += 1
//        }
//
//        FirebaseAPI.addToGroupPlaylist(group: group, data: tracks)
//    }
    
    @objc func addSongsButtonClicked() {
        performSegue(withIdentifier: "toAddSongsToPlaylist", sender: nil)
    }
    
    func doneSelecting(selected: [BaseTrack]) {
        //addSongsToPlaylist(tracks: selected)
        FirebaseAPI.addToGroupPlaylist(group: group, playlist: songs, selected: selected)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barAddSongsButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toAddSongsToPlaylist", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddSongsToPlaylist") {
            let navVC = segue.destination as! UINavigationController
            let segueVC = navVC.topViewController as! SearchSongsTableViewController
            segueVC.searchSongsDelegate = self
            segueVC.showCancelButton = true
            segueVC.doneButton.title = "Done"
        }
    }
}
