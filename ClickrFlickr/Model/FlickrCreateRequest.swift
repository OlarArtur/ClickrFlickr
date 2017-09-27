//
//  CreateRequestAndGetResponse.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class FlickrCreateRequest {
    
    func getOauthParametersByNeededParameters(oauthParam: [String: String], neededParam: [String]) -> [String] {
        
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
    
    func concatenateBaseUrlString(urlString: String, parameters: [String]) -> String? {
        
        var concatenatedString = ""
        
        concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
        let urlCustomAllowedSet = CharacterSet(charactersIn: "/:=&%").inverted
        
        guard let guardString = concatenatedString.addingPercentEncoding(withAllowedCharacters: urlCustomAllowedSet) else {
            return nil
        }
        concatenatedString = "GET&" + guardString.replacingOccurrences(of: "?", with: "&")
        return concatenatedString
    }
    
    func concatenateRequestUrlString(urlString: String, parameters: [String]) -> String {
        
        var concatenatedString = ""
        
        concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
        return concatenatedString
    }
    
    func getUrlPartWithSortedParameters(arrayOfParameters: [String]) -> String {
        
        let sortedArray = arrayOfParameters.sorted()
        let stringFromArray = sortedArray.joined(separator: "&")
        return stringFromArray
    }
    
    func getSignatureFromStringWithEncodedCharact(string: String, apiSecretKey: String, tokenSecret: String?) -> String {
        
        var key: String
        
        if let tokenSecret = tokenSecret {
            key = "\(apiSecretKey)&\(tokenSecret)"
        } else {
            key = "\(apiSecretKey)&"
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        var signature = string.hmac(algorithm: Encryption.HMACAlgorithm.SHA1, key: key)
        signature = signature.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        return signature
    }
    
}
