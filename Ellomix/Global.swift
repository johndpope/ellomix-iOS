//
//  Global.swift
//  Ellomix
//
//  Created by Kevin Avila on 9/17/17.
//  Copyright © 2017 Akshay Vyas. All rights reserved.
//

import Foundation

class Global {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobal = Global()
    
    var user:EllomixUser? = nil
    var youtubePlayer:YouTubePlayerView? = nil
    var musicPlayer:MusicPlayer = MusicPlayer()
}
