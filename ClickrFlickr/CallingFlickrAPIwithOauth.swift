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
    private static var oauthVerifier: String?
    private static var oauthTokenSecret: String?
    
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
                          ParametersConstants.authMethod : "flickr.test.login",
                          ParametersConstants.authFormat : "json",
                          ParametersConstants.authNoJsonCallback : "1"]
        
        if let oauthConsumerKey = CallingFlickrAPIwithOauth.apiKey {
            dictionary[ParametersConstants.oauthConsumerKey] = oauthConsumerKey
        }
        
        if let oauthSignature = oauthSignature {
            dictionary[ParametersConstants.oauthSignature] = oauthSignature
        }
        
        if let oauthToken = UserDefaults.standard.object(forKey: "token") as? String {
            dictionary[ParametersConstants.oauthToken] = oauthToken
        }
        
        if let oauthTokenSecret = oauthTokenSecret {
            dictionary[ParametersConstants.oauthTokenSecret] = oauthTokenSecret
        }
        
        if let oauthVerifier = oauthVerifier {
            dictionary[ParametersConstants.oauthVerifier] = oauthVerifier
        }
        
        return dictionary
    }
    
    
    class func getJSON() {
        
        let neededParameters = [ParametersConstants.authMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.authFormat, ParametersConstants.authNoJsonCallback, ParametersConstants.oauthToken, ParametersConstants.oauthNonce, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthVersion, ParametersConstants.oauthSignature]
    
        var oauthParameters = getOauthParametersByNeededParameters(oauthParam: authParameters(), neededParam: neededParameters)
        let baseString = concatenateUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters, isBaseString: true)
        
        if let tokenSecret = UserDefaults.standard.object(forKey: "tokensecret") as? String, let apiSecretKey = apiSecretKey {
            self.oauthSignature = getSignatureFromStringWithEncodedCharact(string: baseString, apiSecretKey: apiSecretKey, tokenSecret: tokenSecret)
        } else {
            print("ERROR CallingFlickrAPIwithOauth: tokenSecret or apiSecretKey is empty ")
        }
        
        oauthParameters = getOauthParametersByNeededParameters(oauthParam: authParameters(), neededParam: neededParameters)
        let urlRequest = concatenateUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters, isBaseString: false)
        print(urlRequest)
        getResponseFromUrl(link: urlRequest) { (result) in
            print(result)
        }
        
    }


//    private static func getDate() -> String {
//        
//        let dateformatter = DateFormatter()
//    
//        dateformatter.dateFormat = "yyyy-MM-dd"
//        
//        let calendar = Calendar.current
//        
//        let yersterday = calendar.date(byAdding: .day, value: -1, to: Date())
//        
//        let nowMinusDay = dateformatter.string(from: yersterday!)
//        
//        return nowMinusDay
//    }
    
    
}
