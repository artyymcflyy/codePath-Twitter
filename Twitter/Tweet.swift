//
//  Tweet.swift
//  Twitter
//
//  Created by Arthur Burgin on 4/12/17.
//  Copyright © 2017 Arthur Burgin. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var name: String?
    var screenname: String?
    var profileImageUrl: URL?
    var timestamp: Date?
    var currTimeStamp: String?
    var detailTimeStamp: String?
    var tweet_id: String?
    var retweet_id: String?
    var retweeted: Bool?
    var retweetedStatus: NSDictionary?
    var retweetedText: String?
    var retweetedUsername: String?
    var retweetedName: String?
    var retweetedProfileUrl: URL?
    var favorited: Bool?
    var retweetedRetweets: Int = 0
    var retweetedFavorites: Int = 0
    var retweetedRetweetCount: Int = 0
    var retweetCount: Int = 0
    var retweetedFavoritesCount: Int = 0
    var favoritesCount: Int  = 0
    let currTime = Date()
    var minutes:Int = 0
    var hours: Int = 0
    var days: Int = 0
    var rawTime:Int = 0
    
    init(dictionary: NSDictionary){
        let user = dictionary["user"] as! NSDictionary
        
        name  = user["name"] as? String
        screenname = "@\(user["screen_name"] ?? "")"
        text = dictionary["text"] as? String
        let profileImageString = user["profile_image_url"] as? String
        if let profileImageString = profileImageString{
            profileImageUrl = URL(string: profileImageString)
        }
        tweet_id = dictionary["id_str"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        retweeted = dictionary["retweeted"] as? Bool
        retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        if retweetedStatus != nil{
            retweetedText = retweetedStatus?["text"] as? String
            retweetedRetweets = retweetedStatus?["retweet_count"] as? Int ?? 0
            retweetedFavorites = retweetedStatus?["favorite_count"] as? Int ?? 0
            retweet_id = retweetedStatus?["id_str"] as? String

            let retweetedFromUser = retweetedStatus?["user"] as? NSDictionary
            retweetedUsername = "@\(retweetedFromUser?["screen_name"] as? String ?? "")"
            retweetedName = retweetedFromUser?["name"] as? String
            retweetedProfileUrl = retweetedFromUser?["profile_image_url"] as? URL
            
        }
        
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        favorited = dictionary["favorited"] as? Bool
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString{
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString)
            detailTimeStamp = DateFormatter.localizedString(from: timestamp!, dateStyle: .short, timeStyle: .short)
        }
        
        rawTime = Int(currTime.timeIntervalSince(timestamp!))
        minutes = rawTime/60
        hours = rawTime/3600
        days = rawTime/86400
        
        if rawTime < 60{
            currTimeStamp = "\(rawTime)s"
        }
        if rawTime >= 60{
            if rawTime < 3600{
               currTimeStamp = "\(minutes)m"
            }
        }
        if rawTime >= 3600{
            if rawTime < 86400{
                currTimeStamp = "\(hours)h"
            }
        }
        if rawTime >= 86400{
            currTimeStamp = timestamp?.description
        }

        
    }
    
    //tweet helper
    class func tweetsInArray(dictionaries: [NSDictionary]) -> [Tweet]{
        var tweets = [Tweet]()
        
        for dictionary in dictionaries{
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
    

}
