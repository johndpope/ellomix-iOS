//
//  YoutubeService.swift
//  Ellomix
//
//  Created by Kevin Avila on 8/14/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import Alamofire

class YoutubeService {
    
    let YouTubeAPIKey = "AIzaSyDl9doicP6uc4cEVlRDiM7Ttgy-o7Hal3I"
    var youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search"
    
    func search(query: String, completed: @escaping ([YouTubeVideo]) -> ()) {
        var videos = [YouTubeVideo]()
        Alamofire.request(youtubeSearchURL, parameters: ["part":"snippet", "type":"video", "q":query, "maxResults":"50", "key":YouTubeAPIKey]).responseJSON(completionHandler: { response in
            
            print("---------------REQUESTING FROM YOUTUBE-----------------")
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
                    DispatchQueue.global().async {
                        if let thumbnailURL = ytVideo.thumbnailURL, let data = try? Data(contentsOf: URL(string: thumbnailURL)!) {
                            DispatchQueue.main.async {
                                ytVideo.thumbnailImage = UIImage(data: data)
                                completed(videos)
                            }
                        } else {
                            ytVideo.thumbnailImage = #imageLiteral(resourceName: "ellomix_logo_bw")
                        }
                    }
                    
                    videos.append(ytVideo)
                }
                completed(videos)
            }
        })
    }
    
}
