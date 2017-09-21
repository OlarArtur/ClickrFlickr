//
//  CallingFlickrAPIwithOauth.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class CallingFlickrAPIwithOauth: CreateRequestAndGetResponse {
    
    
    private static var apiKey: String?
    private static var apiSecretKey: String?
    
    private static var oauthSignature: String?
    
    private static var oauthTags: String?
    
    class func configureDataAPI(apiKey: String, apiSecretKey: String){
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
    }
    
    private class func authParameters() -> [String : String] {
        
        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))
        
        var dictionary = [ParametersConstants.oauthNonce : oauthNonce,
                          ParametersConstants.oauthTimestamp : oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod : Constants.signatureMethod,
                          ParametersConstants.oauthVersion : Constants.version,
                          ParametersConstants.oauthMethod : Constants.methodPhotosSearch,
                          ParametersConstants.oauthFormat : Constants.format,
                          ParametersConstants.oauthNoJsonCallback : Constants.noJsonCallback]
        
        if let oauthConsumerKey = CallingFlickrAPIwithOauth.apiKey {
            dictionary[ParametersConstants.oauthConsumerKey] = oauthConsumerKey
        }
        
        if let oauthSignature = oauthSignature {
            dictionary[ParametersConstants.oauthSignature] = oauthSignature
        }
        
        if let oauthToken = UserDefaults.standard.object(forKey: "token") as? String {
            dictionary[ParametersConstants.oauthToken] = oauthToken
        }
        
        if let oauthTags = oauthTags {
            dictionary[ParametersConstants.oauthTags] = oauthTags
        }
        
        return dictionary
    }
    
    
    class func getDataJSON(oauthTags: String, completion: @escaping (Data) -> ()) {
        
        self.oauthTags = oauthTags
        
        var neededParameters = [ParametersConstants.oauthMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthFormat, ParametersConstants.oauthNoJsonCallback, ParametersConstants.oauthToken, ParametersConstants.oauthNonce, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthVersion, ParametersConstants.oauthTags]
    
        var oauthParameters = getOauthParametersByNeededParameters(oauthParam: authParameters(), neededParam: neededParameters)
        let baseString = concatenateUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters, isBaseString: true)
        
        if let tokenSecret = UserDefaults.standard.object(forKey: "tokensecret") as? String, let apiSecretKey = apiSecretKey {
            self.oauthSignature = getSignatureFromStringWithEncodedCharact(string: baseString, apiSecretKey: apiSecretKey, tokenSecret: tokenSecret)
        } else {
            print("ERROR CallingFlickrAPIwithOauth: tokenSecret or apiSecretKey is empty ")
        }
        
        neededParameters = [ParametersConstants.oauthSignature]
        oauthParameters = oauthParameters + getOauthParametersByNeededParameters(oauthParam: authParameters(), neededParam: neededParameters)
        
        let urlRequest = concatenateUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters, isBaseString: false)
        
        getResponseFromUrl(link: urlRequest) {(data, result) in
            
            print(data)
            completion(data)
        }
    }
    
    
}
