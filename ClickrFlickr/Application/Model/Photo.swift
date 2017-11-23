//
//  Photo.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 10/30/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


struct Photo {
    let title: String
    let farm: Int
    let server: String
    let id: String
    let secret: String
    let owner: String
    
    var aspectSize: Float
    
    var width: CGFloat?
    var height: CGFloat?
    
    
    var image: UIImage?
    
    var url: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
    init? (dict: [String: Any]) {
        guard let title = dict["title"] as? String,
            let heightS = dict["height_s"] as? String,
            let widthS = dict["width_s"] as? String,
            let farm = dict["farm"] as? Int,
            let server = dict["server"] as? String,
            let id = dict["id"] as? String,
            let secret = dict["secret"] as? String,
            let owner = dict["owner"] as? String else { return nil }
        
        self.aspectSize = Float(heightS)! / Float(widthS)!
        
        self.title = title
        self.farm = farm
        self.server = server
        self.id = id
        self.secret = secret
        self.owner = owner
    }
}
