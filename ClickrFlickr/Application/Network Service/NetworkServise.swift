//
//  NetworkServise.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/2/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class NetworkServise {

    private init() {}
    
    static let shared = NetworkServise()
    
    public func getData(url: URL, completion: @escaping (Data?, URL) -> ()) {
        let session = URLSession.shared
        
        session.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                completion(nil, url)
                return
            }
            completion(data, url)
            
        }.resume()
        
    }
    
}
