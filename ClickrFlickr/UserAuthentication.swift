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
    
    static var apiKey: String = "Set value"
    static var apiSecretKey: String = "Set value"
    static var oauthCallback: String = "Set value"
    
    private var oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
    private var oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))
    
    private var oauthSignature: String?
    private var oauthToken: String?
    private var oauthVerifier: String?
    private var oauthTokenSecret: String?
    
    private var oauthConsumerKey: String {
        return UserAuthentication.apiKey
    }
    
    private var oauthParameters: [String : String]? {
        
        var dictionary = [ParametersConstants.oauthCallback : UserAuthentication.oauthCallback,
                          ParametersConstants.oauthConsumerKey : oauthConsumerKey,
                          ParametersConstants.oauthNonce : oauthNonce,
                          ParametersConstants.oauthTimestamp : oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod : Constants.signatureMethod,
                          ParametersConstants.oauthVersion : Constants.version]
        
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
    
        return dictionary
    }
    
    class func configureDataAPI(apiKey: String, apiSecretKey: String, callback: String){
        
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.oauthCallback = callback
    }
    
    
    func authorize() {
        
        //        1.Get a Request Token
        //        2.Get the User's Authorization
        //        3.Exchange the Request Token for an Access Token
        
        getRequestToken() { (token, secretToken) in
            self.getTheUserAuthorization()
        }
        
//        exchangeRequestTokenForAccessToken()
        
    }
    
    
    private func getRequestToken(completion: @escaping (_ token: String, _ secretToken: String) -> ()) {
        
        var neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthCallback, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp]
        
        var arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
        
        let baseString = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfOauthParameters, isBaseString: true)
        
        getSignatureFromStringWithEncodedCharact(string: baseString)
        
        neededParameters.append(ParametersConstants.oauthSignature)
        
        arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
        
        let urlRequestToken = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfOauthParameters, isBaseString: false)
        
        getResponseFromUrl(link: urlRequestToken) { result in
            
            let response = self.separateResponce(stringToSplit: result)
            
            if response.keys.contains("oauth_token_secret") {
                self.oauthTokenSecret = response["oauth_token_secret"]
            }
            
            if response.keys.contains("oauth_token") {
                self.oauthToken = response["oauth_token"]
            }
            completion(self.oauthTokenSecret!, self.oauthToken!)
        }
    }
    
    
    private func getTheUserAuthorization() {
        
        let neededParameters = [ParametersConstants.oauthToken]
        
        let arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
        
        let urlUserAuthorization = concatenateUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfOauthParameters, isBaseString: false)
        
        let safariView = SFSafariViewController(url: URL(string: urlUserAuthorization)!)

        UIApplication.shared.keyWindow?.rootViewController?.present(safariView, animated: true, completion: nil)
    
        
        
//        UIApplication.shared.delegate.application(UIApplication, open: CFBundle, sourceApplication: String?, annotation: Any) {
//            
//            if url.scheme == "clickrflickr"{
//                let callBackAfterUserAuthorization = url.absoluteString
//            }
//            
//            
//         return true
//        }
        
        
    }
    
    
    private func exchangeRequestTokenForAccessToken() {
        
    }
    
    
    private func getOauthParametersByNeededParameters(oauthParam: [String:String], neededParam: [String]) -> [String] {
        
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
    
    
    private func concatenateUrlString(urlString: String, parameters: [String], isBaseString: Bool) -> String {
        
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
    
    
    private func getUrlPartWithSortedParameters(arrayOfParameters: [String]) -> String {
        
        let sortedArray = arrayOfParameters.sorted()
        let stringFromArray = sortedArray.joined(separator: "&")
        return stringFromArray
    }
    
    
    private func getSignatureFromStringWithEncodedCharact(string: String) {
        
        var key: String
        
        if let oauthTokenSecret = oauthTokenSecret {
            key = "\(UserAuthentication.apiSecretKey)&\(oauthTokenSecret)"
        } else {
            key = "\(UserAuthentication.apiSecretKey)&"
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        oauthSignature = string.hmac(algorithm:Encryption.HMACAlgorithm.SHA1, key: key)
        oauthSignature = oauthSignature?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }
    
    
    private func getResponseFromUrl(link: String, completion: @escaping (String) -> ()) {
        
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
    
    
    private func separateResponce(stringToSplit: String) -> [String: String] {
        
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



