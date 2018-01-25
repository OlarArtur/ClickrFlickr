//
//  FetchJSON.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/26/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class FetchJSON {
    
    private init() {}

    static func fetchJson(fromUrl stringUrl: String, completion: @escaping (AnyObject?)->()) {
        
        guard let url = URL(string: stringUrl) else {
            completion(nil)
            return
        }
        
        NetworkServise.shared.getData(url: url) { (data, url) in
            
            guard let data = data else {
                completion(nil)
                return
            }
//            let startDateOne = Date()
//
//            let decoder = JSONDecoder()
//            do {
//                let stat = try decoder.decode(Stat.self, from: data)
//                let codableTime = Date().timeIntervalSince(startDateOne)
//                print("codable: \(codableTime) sec")
//            } catch {
//                print(error)
//            }
//
//            let startDateTwo = Date()
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
//                let jsonTime = Date().timeIntervalSince(startDateTwo)
//                print("json: \(jsonTime) sec")
                
                completion(json as AnyObject)
            } catch let errorJson {
                completion(nil)
                print(errorJson)
            }
        }
        
    }
    
}


//struct Stat: Codable {
//
//    struct Photos: Codable {
//        struct Photo: Codable {
//
//            let title: String
//            let farm: Int
//            let server: String
//            let id: String
//            let secret: String
//            let owner: String
//            let width_s: String
//            let height_s: String
//
//            struct Description: Codable  {
//                let _content: String
//            }
//
//            let description: Description
//
//        }
//        let photo: [Photo]
//    }
//    let photos: Photos
//
//}

    


