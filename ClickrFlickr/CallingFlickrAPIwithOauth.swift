//
//  CallingFlickrAPIwithOauth.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class CallingFlickrAPIwithOauth {

    private static var apiKey: String?
    private static var apiSecretKey: String?

    class func configureDataAPI(apiKey: String, apiSecretKey: String) {
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
    }

    class func getResponseApi(oauthTags: String) -> String? {

        var neededParameters = NeededParametersForRequest.callingFlickrMethodPhotosSearch
        
        let flickrCreateRequest = FlickrCreateRequest()

        var oauthParameters = flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: authParameters(oauthSignature: nil, oauthTags: oauthTags), neededParam: neededParameters)
        let baseString = flickrCreateRequest.concatenateBaseUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters)

        guard let baseStringCurrent = baseString else {
            print("ERROR CallingFlickrAPIwithOauth: baseString")
            return nil
        }

        guard let tokenSecret = UserDefaults.standard.object(forKey: "tokensecret") as? String, let apiSecretKey = apiSecretKey else {
            print("ERROR CallingFlickrAPIwithOauth: tokenSecret or apiSecretKey is empty ")
            return nil
        }
            let oauthSignature = flickrCreateRequest.getSignatureFromStringWithEncodedCharact(string: baseStringCurrent, apiSecretKey: apiSecretKey, tokenSecret: tokenSecret)

        neededParameters = [ParametersConstants.oauthSignature]
        oauthParameters = oauthParameters + flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: authParameters(oauthSignature: oauthSignature, oauthTags: oauthTags), neededParam: neededParameters)

        let urlRequest = flickrCreateRequest.concatenateRequestUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters)
        
        return urlRequest
        
//        let flickrGetResponse = FlickrGetResponse()
//
//        flickrGetResponse.getResponseFromUrl(link: urlRequest) { (data, _) in
//            guard let data = data else {
//                completion(nil)
//                return
//            }
//            completion(data)
//        }
    }
    
    private class func authParameters(oauthSignature : String?, oauthTags: String?) -> [String: String] {
        
        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))
        
        var dictionary = [ParametersConstants.oauthNonce: oauthNonce,
                          ParametersConstants.oauthTimestamp: oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod: Constants.signatureMethod,
                          ParametersConstants.oauthVersion: Constants.version,
                          ParametersConstants.oauthMethod: Constants.methodPhotosSearch,
                          ParametersConstants.oauthFormat: Constants.format,
                          ParametersConstants.oauthNoJsonCallback: Constants.noJsonCallback]
        
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

}
