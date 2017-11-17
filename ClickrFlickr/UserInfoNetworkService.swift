//
//  UserInfoNetworkService.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/16/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class UserInfoNetworkservice {
    
    private init() {}
    
    static func getUserInfo (for userId: String, completion: @escaping (User)->()) {
        guard let string = CallingFlickrAPIwithOauth.methodPeopleGetInfo(userId: userId) else {return}
        
        FetchJSON.fetchJson(fromUrl: string) { (json) in
            
            guard let json = json else {return}
        
            do {
                let user = try CreateUserInfo(json: json).userInfo
                DispatchQueue.main.async {
                    completion(user)
                }
            } catch {
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "ERROR! Fetching JSON for search Photo", message: "Try again?")
            }
        }
    }
    
}

