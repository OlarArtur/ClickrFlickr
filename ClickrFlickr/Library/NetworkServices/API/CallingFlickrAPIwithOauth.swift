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

    private class func getResponseApi(neededParameters: [String], oauthText: String?, oauthUserId: String?, isUserIdForPhoto: Bool?) -> String? {

        var neededParameters = neededParameters
        
        let flickrCreateRequest = FlickrCreateRequest()

        var oauthParameters = flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: authParameters(oauthSignature: nil, oauthText: oauthText, oauthUserId: oauthUserId, isUserIdForPhoto: isUserIdForPhoto), neededParam: neededParameters)
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
        oauthParameters = oauthParameters + flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: authParameters(oauthSignature: oauthSignature, oauthText: oauthText, oauthUserId: oauthUserId, isUserIdForPhoto: isUserIdForPhoto), neededParam: neededParameters)

        let urlRequest = flickrCreateRequest.concatenateRequestUrlString(urlString: Constants.apiRequestUrl, parameters: oauthParameters)
        
        return urlRequest
        
    }
    
    class func methodPhotosSearch(oauthText: String) -> String? {
        let urlRequest = getResponseApi(neededParameters: NeededParametersForRequest.callingFlickrMethodPhotosSearch, oauthText: oauthText, oauthUserId: nil, isUserIdForPhoto: nil)
        return urlRequest
    }
    
    class func methodInterestingnessGetList() -> String? {
        let urlRequest = getResponseApi(neededParameters: NeededParametersForRequest.callingFlickrMethodInterestingnessGetList, oauthText: nil, oauthUserId: nil, isUserIdForPhoto: nil)
        return urlRequest
    }
    
    class func methodPeopleGetPhoto(userId: String) -> String? {
        let urlRequest = getResponseApi(neededParameters: NeededParametersForRequest.callingFlickrMethodPeopleGetPhotos, oauthText: nil, oauthUserId: userId, isUserIdForPhoto: true)
        return urlRequest
    }
    
    class func methodPeopleGetInfo(userId: String) -> String? {
        let urlRequest = getResponseApi(neededParameters: NeededParametersForRequest.callingFlickrMethodPeopleGetInfo, oauthText: nil, oauthUserId: userId, isUserIdForPhoto: false)
        return urlRequest
    }
    
    private class func authParameters(oauthSignature : String?, oauthText: String?, oauthUserId: String?, isUserIdForPhoto: Bool?) -> [String: String] {
        
        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(Date().timeIntervalSince1970))
        
        var dictionary = [ParametersConstants.oauthNonce: oauthNonce,
                          ParametersConstants.oauthTimestamp: oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod: Constants.signatureMethod,
                          ParametersConstants.oauthVersion: Constants.version,
                          ParametersConstants.oauthFormat: Constants.format,
                          ParametersConstants.oauthMethod: Constants.methodInterestingnessGetList,
                          ParametersConstants.oauthNoJsonCallback: Constants.noJsonCallback,
                          ParametersConstants.oauthExtras: Constants.extras]
        
        if let oauthConsumerKey = CallingFlickrAPIwithOauth.apiKey {
            dictionary[ParametersConstants.oauthConsumerKey] = oauthConsumerKey
        }
        
        if let oauthSignature = oauthSignature {
            dictionary[ParametersConstants.oauthSignature] = oauthSignature
        }
        
        if let oauthToken = UserDefaults.standard.object(forKey: "token") as? String {
            dictionary[ParametersConstants.oauthToken] = oauthToken
        }
        
        if let oauthText = oauthText {
            dictionary[ParametersConstants.oauthText] = oauthText
            dictionary[ParametersConstants.oauthMethod] = Constants.methodPhotosSearch
            dictionary[ParametersConstants.oauthSort] = Constants.sort
        }
        
        guard let isIdForPhoto = isUserIdForPhoto else {return dictionary}
        
        if let oauthUserId = oauthUserId {
            if isIdForPhoto {
                dictionary[ParametersConstants.oauthUserId] = oauthUserId
                dictionary[ParametersConstants.oauthMethod] = Constants.methodPeopleGetPhotos
            } else {
                dictionary.removeValue(forKey: ParametersConstants.oauthSort)
                dictionary[ParametersConstants.oauthUserId] = oauthUserId
                dictionary[ParametersConstants.oauthMethod] = Constants.methodPeopleGetInfo
            }
        }
        return dictionary
    }

}
