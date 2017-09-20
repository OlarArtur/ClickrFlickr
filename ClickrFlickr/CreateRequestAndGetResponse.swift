//
//  CreateRequestAndGetResponse.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class CreateRequestAndGetResponse {
    
    
     static func getOauthParametersByNeededParameters(oauthParam: [String:String], neededParam: [String]) -> [String] {
        
        var resultArray = [String]()
        
        for (key, value) in oauthParam {
            for member in neededParam {
                if member == key {
                    let stringSum = "\(key)=\(value)"
                    resultArray.append(stringSum)
                }
            }
        }
        return resultArray
    }
    
    
    static func concatenateUrlString(urlString: String, parameters: [String], isBaseString: Bool) -> String {
        
        var concatenatedString = ""
        
        guard isBaseString else {
            concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
            return concatenatedString
        }
        
        concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
        let urlCustomAllowedSet = CharacterSet(charactersIn: "/:=&%").inverted
        
        guard let guardString = concatenatedString.addingPercentEncoding(withAllowedCharacters: urlCustomAllowedSet) else {
            concatenatedString = "GET&" + concatenatedString.replacingOccurrences(of: "?", with: "&")
            return concatenatedString
        }
        concatenatedString = "GET&" + guardString.replacingOccurrences(of: "?", with: "&")
        return concatenatedString
    }
    
    
    static func getUrlPartWithSortedParameters(arrayOfParameters: [String]) -> String {
        
        let sortedArray = arrayOfParameters.sorted()
        let stringFromArray = sortedArray.joined(separator: "&")
        return stringFromArray
    }
    
    
    static func getSignatureFromStringWithEncodedCharact(string: String, apiSecretKey: String, tokenSecret: String?) -> String {
        
        var key: String
        
        if let tokenSecret = tokenSecret {
            key = "\(apiSecretKey)&\(tokenSecret)"
            print(key)
        } else {
            key = "\(apiSecretKey)&"
            print(key)
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        var signature = string.hmac(algorithm:Encryption.HMACAlgorithm.SHA1, key: key)
        signature = signature.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        return signature
    }
    
    
    static func getResponseFromUrl(link: String, completion: @escaping (Data, String) -> ()) {
        
        guard let url = URL(string: link) else {
            print("Error: cannot create URL")
            return
        }
        
        urlSessionTask(url: url) { (data, error) in
            
            guard let data = data else {
                print("data is nil")
                return
            }
            
            guard let responseString = String(data: data, encoding: String.Encoding.utf8) else {
                completion(data, "Can't convert data to string")
                return
            }
            completion(data, responseString)
        }
    }
    
    
    static func urlSessionTask(url: URL, competion: @escaping (Data?, Error?) -> ()) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            
            if let error = error{
                print(error)
                competion(nil, error)
            } else {
                if let data = data{
                    competion(data, nil)
                } else {
                    competion(nil, nil)
                }
            }
        }
        task.resume()
    }
    
    
    static func separateResponce(stringToSplit: String) -> [String: String] {
        
        var separatedResponse: [String : String] = [:]
        var splitedString = ""
        
        if let array = stringToSplit.components(separatedBy: "?").last {
            splitedString = array
        }
        
        let array = splitedString.components(separatedBy: "&")
        for element in array {
            let array = element.components(separatedBy: "=")
            separatedResponse[array[0]] = array[1]
        }
        return separatedResponse
    }

    
}
