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
    
    func jsonToSerchPhoto(stringUrl: String, completion: @escaping ([[String: String]]?)->()) {
        
        var arrayPhotosData = [[String: String]]()
        
        fetchJsonFromUrl(stringUrl: stringUrl) { (json) in
            
            guard let json = json else {return}
            
            guard let photos = json["photos"] as? [String: Any] else {return}
            
            guard let photo = photos["photo"] as? [[String: Any]] else {return}
            
            for arrayValue in photo {
                
                var helpDict: [String: String] = [:]
                
                for (key, value) in arrayValue {
                    switch key {
                    case "title", "owner", "server", "id", "secret", "farm":
                        let valueStr = String(describing: value)
                        helpDict[key] = valueStr
                    default:
                        break
                    }
                }
                arrayPhotosData.append(helpDict)
                completion(arrayPhotosData)
            }
        }
    }
    
}

