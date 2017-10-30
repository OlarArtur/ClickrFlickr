//
//  FetchJSON.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/26/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class FetchJSON {

    func fetchJsonFromUrl(stringUrl: String, completion: @escaping (AnyObject?)->()) {
        
        guard let url = URL(string: stringUrl) else {return}
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {return}
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                completion(json as AnyObject)
            } catch let errorJson {
                print(errorJson)
            }
        }.resume()
        
    }
    
    func getSerchPhotos(stringUrl: String, completion: @escaping ([Photo]?)->()) {
        
        var searchPhotos = [Photo]()
        
        fetchJsonFromUrl(stringUrl: stringUrl) { (json) in
            
            guard let json = json else {return}
            
            guard let photos = json["photos"] as? [String: Any] else {return}
            
            guard let photo = photos["photo"] as? [[String: Any]] else {return}
            
            _ = photo.map { element in
                guard let title = element["title"] as? String,
//                let owner = String(describing: element["owner"])
                let server = element["server"] as? String,
                let id = element["id"] as? String,
                let secret = element["secret"] as? String,
                let farm = element["farm"] as? Int  else {return}
                searchPhotos.append(Photo(title: title, farm: farm, server: server, id: id, secret: secret))
            }
            completion(searchPhotos)
        }
    }
    
}

