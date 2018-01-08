//
//  CreateUserInfo.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/16/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class CreateUserInfo {
    
    var userInfo: UserInfo
    
    init (json: AnyObject) throws {
        
        var userInfoDictionary = [String: AnyObject]()
        
        guard let person = json["person"] as? [String: Any] else { throw FlickOauthError.NetworkServiseError }
        userInfoDictionary["nsid"] = person["nsid"] as? NSString
        userInfoDictionary["ispro"] = person["ispro"] as AnyObject
        userInfoDictionary["iconserver"] = person["iconserver"] as AnyObject
        userInfoDictionary["iconfarm"] = person["iconfarm"] as AnyObject
        guard let photos = person["photos"] as? [String: AnyObject] else { throw FlickOauthError.NetworkServiseError }
        guard let count = photos["count"] as? [String: AnyObject] else { throw FlickOauthError.NetworkServiseError }
        userInfoDictionary["count"] = count["_content"] as AnyObject
        guard let name = person["username"] as? [String: AnyObject] else { throw FlickOauthError.NetworkServiseError }
        userInfoDictionary["username"] = name["_content"] as AnyObject
        if let full = person["realname"] as? [String: AnyObject] {
            userInfoDictionary["realname"] = full["_content"] as AnyObject
        } else {
            userInfoDictionary["realname"] = "" as AnyObject
        }
        guard let user = UserInfo(dict: userInfoDictionary) else { throw FlickOauthError.NetworkServiseError }
        userInfo = user
    }
    
}
