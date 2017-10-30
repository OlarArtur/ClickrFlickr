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
    
    var url: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
