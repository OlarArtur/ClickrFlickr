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
        
        NetworkServise.shared.getData(url: url) { (data) in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                completion(json as AnyObject)
            } catch let errorJson {
                print(errorJson)
            }
        }
        
    }
    
    func getSerchPhotos(stringUrl: String, completion: @escaping ([Photo]?)->()) {
        
        fetchJsonFromUrl(stringUrl: stringUrl) { (json) in
            
            guard let json = json else {
                completion(nil)
                return
            }
            
            guard let photos = json["photos"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            guard let photo = photos["photo"] as? [[String: Any]] else {
                completion(nil)
                return
            }
            
            var searchPhotos = [Photo]()
            
            for element in photo {
                guard let photo = Photo(dict: element) else { continue }
                searchPhotos.append(photo)
            }
            DispatchQueue.main.async {
                completion(searchPhotos)
            }
        }
    }
    
}

    


