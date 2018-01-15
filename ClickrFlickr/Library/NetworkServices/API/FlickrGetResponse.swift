//
//  CreateRequestAndGetResponse.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class FlickrGetResponse {
    
    func getResponseFromUrl(link: String, completion: @escaping (Data?, String?) -> ()) {
        
        guard let url = URL(string: link) else {
            completion(nil, nil)
            return
        }

        NetworkServise.shared.getData(url: url) { (data, url) in
            guard let data = data else {
                completion(nil, nil)
                return
            }
        
            guard let responseString = String(data: data, encoding: String.Encoding.utf8) else {
                completion(nil, nil)
                return
            }
            DispatchQueue.main.async {
                completion(data, responseString)
            }
        }
    }
    
    func separateResponce(stringToSplit: String) -> [String: String]? {
        
        var separatedResponse: [String: String] = [:]
        var splitedString = stringToSplit
        
        if let stringParam = splitedString.components(separatedBy: "?").last {
            splitedString = stringParam
        }
        
        guard splitedString.contains("=") else {return nil}
        
        if splitedString.contains("&") {
            let array = splitedString.components(separatedBy: "&")
            for element in array {
                let array = element.components(separatedBy: "=")
                guard let key = array.first, let value = array.last else {return nil}
                separatedResponse[key] = value
            }
            return separatedResponse
        } else {
            let array = splitedString.components(separatedBy: "=")
            guard let key = array.first, let value = array.last else {return nil}
            separatedResponse[key] = value
        }
        return separatedResponse
    }
    
}
