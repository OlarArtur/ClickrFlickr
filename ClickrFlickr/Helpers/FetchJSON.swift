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
        
        guard let url = URL(string: stringUrl) else {return}
        
        NetworkServise.shared.getData(url: url) { (data) in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                DispatchQueue.main.async {
                    completion(json as AnyObject)
                }
            } catch let errorJson {
                print(errorJson)
            }
        }
        
    }
    
}

    


