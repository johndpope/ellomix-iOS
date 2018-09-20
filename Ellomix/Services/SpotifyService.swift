//
//  SpotifyService.swift
//  Ellomix
//
//  Created by Abelardo Torres on 9/19/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import Foundation
import Alamofire

class SpotifyService {
    
    static let KEY_ACCESS_TOKEY = "Ellomix.Ellomix.spotifyAccessToken"
    
    static let apiUrl = URL(string: "https://api.spotify.com/v1/search")
    
    static func search(query: String, completed: @escaping (Data?) -> ()) {
        
        guard let baseUrl = apiUrl else {
            return
        }
        var urlQueryRequest: URLRequest?
        
        let urlRequest = URLRequest(url: baseUrl)
        
        let parameters: Parameters = ["query": query, "type": "track"]
        do {
            urlQueryRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        }
        catch {
            return
        }
        
//        let userDefaults = UserDefaults.standard
//
//        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
        
            print("session exists")
//            let sessionDataObj = sessionObj as! Data
//            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
        //session.accessToken to get access token
        
//            let session = firstTimeSession
            let headers: HTTPHeaders = [
                "Authorization": "Bearer BQA1wosUMNlD-eNtJdQInGwPUK6DjlrGaU8SSMfUBT0kzB4po71zFXVkgYZtX7BWAMQU6tHhdp9fUX37_ZdYnF9fhGtC36AQDE4vzxlrtaWCfGHpe9-7vpe-xX2_ezM0XtgywYTd79FRJe4b6_ae",
                "Accept": "application/json"
            ]
            
            if let urlQueryString = urlQueryRequest?.url?.absoluteString {
                Alamofire.request(urlQueryString, headers: headers).responseJSON { response in
                    debugPrint(response)
                    completed(response.data)
                }
            }
            
            
//        }
        
    }
}
