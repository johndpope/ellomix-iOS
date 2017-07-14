//
//  AudioViewController.swift
//  Ellomix
//
//  Created by Akshay Vyas on 2/28/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var image = UIImage()
    var mainSongTitle = String()
    var mainPreviewUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        songTitleLabel.text = mainSongTitle
        background.image = image
        mainImageView.image = image
        playPauseButton.setTitle("Pause", for: .normal)
        
        downloadFileFromURL(url : URL(string : mainPreviewUrl)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadFileFromURL(url : URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in
            self.play(url : customURL!)
        })
        
        downloadTask.resume()
    }
    
    func play(url : URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func pausePlayAction(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
        }
        else {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
