//
//  User.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/16/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


struct User {
    
    var userName: String
    var realName: String
    let id: String
    let iconServer: String
    let iconFarm: Int
    let isPro: NSNumber
    let photoCount: Int
    
    var avatar: UIImage?
    
    var urlAvatar: String {
        if Int(iconServer) == 0 || iconFarm == 0 {
            return "https://www.flickr.com/images/buddyicon.gif"
        } else {
            return "http://farm\(iconFarm).staticflickr.com/\(iconServer)/buddyicons/\(id).jpg"
        }
    }
    
    init? (dict: [String: Any]) {
        guard let userName = dict["username"] as? String,
            let photoCount = dict["count"] as? Int,
            let realName = dict["realname"] as? String,
            let iconFarm = dict["iconfarm"] as? Int,
            let id = dict["nsid"] as? NSString,
            let iconServer = dict["iconserver"] as? String,
            let isPro = dict["ispro"] as? NSNumber else { return nil }
        
        self.userName = userName
        self.realName = realName
        self.iconFarm = iconFarm
        self.id = String(id)
        self.iconServer = iconServer
        self.isPro = isPro
        self.photoCount = photoCount
    }
}
