//
//  UserAuthentication.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import SafariServices


private struct Constants {
    
    static let signatureMethod: String = "HMAC-SHA1"
    static let version: String = "1.0"
    static let requestTokenUrl: String = "https://www.flickr.com/services/oauth/request_token?"
    static let authorizeUrl: String = "https://www.flickr.com/services/oauth/authorize?"
    static let accessTokenUrl: String = "https://www.flickr.com/services/oauth/access_token?"
}


private struct ParametersConstants {
    
    static let oauthNonce: String = "oauth_nonce"
    static let oauthTimestamp: String = "oauth_timestamp"
    static let oauthConsumerKey: String = "oauth_consumer_key"
    static let oauthSignatureMethod: String = "oauth_signature_method"
    static let oauthVersion: String = "oauth_version"
    static let oauthCallback: String = "oauth_callback"
    static let oauthSignature: String = "oauth_signature"
    static let oauthToken: String = "oauth_token"
    static let oauthVerifier: String = "oauth_verifier"
    static let oauthTokenSecret: String = "oauth_token_secret"
}


class  UserAuthentication {
    
    private static var apiKey: String?
    private static var apiSecretKey: String?
    private static var oauthCallback: String?
    
    private static var oauthSignature: String?
    private static var oauthToken: String?
    private static var oauthVerifier: String?
    private static var oauthTokenSecret: String?
    
    private static var oauthParameters: [String : String] {
        
        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))
        
        var dictionary = [ParametersConstants.oauthNonce : oauthNonce,
                          ParametersConstants.oauthTimestamp : oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod : Constants.signatureMethod,
                          ParametersConstants.oauthVersion : Constants.version]
        
        if let oauthConsumerKey = UserAuthentication.apiKey {
            dictionary[ParametersConstants.oauthConsumerKey] = oauthConsumerKey
        }
        
        if let oauthSignature = oauthSignature {
            dictionary[ParametersConstants.oauthSignature] = oauthSignature
        }
        
        if let oauthToken = oauthToken {
            dictionary[ParametersConstants.oauthToken] = oauthToken
        }
        
        if let oauthTokenSecret = oauthTokenSecret {
            dictionary[ParametersConstants.oauthTokenSecret] = oauthTokenSecret
        }
        
        if let oauthVerifier = oauthVerifier {
            dictionary[ParametersConstants.oauthVerifier] = oauthVerifier
        }
        
        if let oauthCallback = UserAuthentication.oauthCallback  {
            dictionary[ParametersConstants.oauthCallback ] = oauthCallback
        }
    
        return dictionary
    }
    
    class func configureDataAPI(apiKey: String, apiSecretKey: String, callback: String){
        
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.oauthCallback = callback
    }
    
    class func takeURLScheme(url: URL) -> Bool{
        
        if url.scheme == "clickrflickr"{
            
            let callBackAfterUserAuthorization = url.absoluteString
            
            exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: callBackAfterUserAuthorization)
            
            print("User authorized now")
            return true
        } else {
            print("User was not authorize")
            return false
        }
        
    }
    
    
    class func authorize() {
        
        //  3 steps User Authentication:
        //        1.Get a Request Token
        //        2.Get the User's Authorization
        //        3.Exchange the Request Token for an Access Token
        
        getRequestToken() { (token, secretToken) in
            getTheUserAuthorization()
        }
    }
    
    
    private static func getRequestToken(completion: @escaping (_ token: String, _ secretToken: String) -> ()) {
        
        let neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthCallback, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp]

        let urlRequestToken = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.requestTokenUrl)
        
        getResponseFromUrl(link: urlRequestToken) { result in
            
            let response = self.separateResponce(stringToSplit: result)
            
            if response.keys.contains("oauth_token_secret") {
                
                oauthTokenSecret = response["oauth_token_secret"]
                
                if response.keys.contains("oauth_token") {
                    oauthToken = response["oauth_token"]
                } else {
                    completion("error Token", "error")
                }
                
                completion(oauthTokenSecret!, oauthToken!)
                
            } else {
                completion("error", "error secretToken")
            }
        }
    }
    
    
    private static func getTheUserAuthorization() {
        
        let neededParameters = [ParametersConstants.oauthToken]
        
        let arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        
        let urlUserAuthorization = concatenateUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfOauthParameters, isBaseString: false)
        
        let safariView = SFSafariViewController(url: URL(string: urlUserAuthorization)!)

        UIApplication.shared.keyWindow?.rootViewController?.present(safariView, animated: true, completion: nil)
    }
    
    
    private static func exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: String) {
        
        let paramAfterUserAuthorization = separateResponce(stringToSplit: callBackAfterUserAuthorization)
        
        if paramAfterUserAuthorization.keys.contains("oauth_token") {
            oauthToken = paramAfterUserAuthorization["oauth_token"]
        } else {
            print("error token")
        }
        if paramAfterUserAuthorization.keys.contains("oauth_verifier") {
            oauthVerifier = paramAfterUserAuthorization["oauth_verifier"]
        } else {
            print("error verifier")
        }
        
        let neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthVerifier, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthToken]
        
        let urlRequestAccess = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.accessTokenUrl)
        
        getResponseFromUrl(link: urlRequestAccess) { result in
            
            let response = self.separateResponce(stringToSplit: result)
            print(response)
            
            if response.keys.contains("oauth_token_secret") {
                oauthTokenSecret = response["oauth_token_secret"]
                print(oauthTokenSecret!)
            } else {
                print("error AccessSecretToken")
            }
            
            if response.keys.contains("oauth_token") {
                oauthToken = response["oauth_token"]
                print(oauthToken!)
            } else {
                print("error AccessToken")
            }
        }
    }
    
    
    private static func getRequestURL(neededOauthParameters: [String], requestURL: String) -> String {
        
        var neededParameters = neededOauthParameters
        var arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        let baseString = concatenateUrlString(urlString: requestURL, parameters: arrayOfOauthParameters, isBaseString: true)
        getSignatureFromStringWithEncodedCharact(string: baseString)
        neededParameters = [ParametersConstants.oauthSignature]
        arrayOfOauthParameters = arrayOfOauthParameters + getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        let urlRequest = concatenateUrlString(urlString: requestURL, parameters: arrayOfOauthParameters, isBaseString: false)
        
        return urlRequest
    }
    
    
    private static func getOauthParametersByNeededParameters(oauthParam: [String:String], neededParam: [String]) -> [String] {
        
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
    
    
    private static func concatenateUrlString(urlString: String, parameters: [String], isBaseString: Bool) -> String {
        
        var concatenatedString = ""
        
        if isBaseString {
            concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
            let urlCustomAllowedSet = CharacterSet(charactersIn: "/:=&%").inverted
            concatenatedString = "GET&" + ((concatenatedString.addingPercentEncoding(withAllowedCharacters: urlCustomAllowedSet))!.replacingOccurrences(of: "?", with: "&"))
        } else {
            concatenatedString = urlString + getUrlPartWithSortedParameters(arrayOfParameters: parameters)
        }
        return concatenatedString
    }
    
    
    private static func getUrlPartWithSortedParameters(arrayOfParameters: [String]) -> String {
        
        let sortedArray = arrayOfParameters.sorted()
        let stringFromArray = sortedArray.joined(separator: "&")
        return stringFromArray
    }
    
    
    private static func getSignatureFromStringWithEncodedCharact(string: String) {
        
        var key: String
        
        guard let apiSecretKey = UserAuthentication.apiSecretKey else {return}
        
        if let oauthTokenSecret = oauthTokenSecret {
            key = "\(apiSecretKey)&\(oauthTokenSecret)"
        } else {
            key = "\(apiSecretKey)&"
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        oauthSignature = string.hmac(algorithm:Encryption.HMACAlgorithm.SHA1, key: key)
        oauthSignature = oauthSignature?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }
    
    
    private static func getResponseFromUrl(link: String, completion: @escaping (String) -> ()) {
        
        var responseString = ""
        
        guard let url = URL(string: link) else {
            completion("Error: cannot create URL")
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            
            if let error = error{
                print(error)
                completion("error in session")
            }
            if let data = data{
                responseString = String(data: data, encoding: String.Encoding.utf8)!
                completion(responseString)
            }
        }.resume()
        
    }
    
    
    private static func separateResponce(stringToSplit: String) -> [String: String] {
        
        var result = [String:String]()
        var splitedString = ""
        
        if stringToSplit.contains("?") {
            let array = stringToSplit.components(separatedBy: "?")
            splitedString = array[1]
        } else {
            splitedString = stringToSplit
        }
        
        let array = splitedString.components(separatedBy: "&")
        for element in array {
            let array = element.components(separatedBy: "=")
            result[array[0]] = array[1]
        }
        return result
    }
    
    
    
    
    
}



