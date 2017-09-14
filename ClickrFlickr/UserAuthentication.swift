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


protocol DetailViewControllerDelegate: class {
    func didFinishTask()
}




class  UserAuthentication {
    
    static weak var delegate: DetailViewControllerDelegate?
    
    
    private static var apiKey: String?
    private static var apiSecretKey: String?
    private static var oauthCallback: String?
    
    private static var oauthSignature: String?
    private static var oauthToken: String?
    private static var oauthVerifier: String?
    private static var oauthTokenSecret: String?
    
    private static var isAuthorized: Bool {
        let nameObject = UserDefaults.standard.object(forKey: "username")
        if let _ = nameObject {
            return true
        } else {
            return false
        }
    }
    
    
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
            print(callBackAfterUserAuthorization)
            exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: callBackAfterUserAuthorization) {(token, secretToken, username, fullname, usernsid) in
                delegate?.didFinishTask()
            }
            
            return true
        } else {
            return false
        }
    }
    
    
    class func getIsAuthorized() -> Bool{
        if isAuthorized{
            return true
        } else {
            return false
        }
    }
    
    
    class func authorize(){
        
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
            print(response)
            
            guard response.keys.contains("oauth_token_secret") else {return completion("error", "requestSecretToken is empty")}
            oauthTokenSecret = response["oauth_token_secret"]
            
            guard response.keys.contains("oauth_token") else {return completion("requestToken is empty", "error")}
            oauthToken = response["oauth_token"]
            
            completion(oauthTokenSecret!, oauthToken!)
        }
    }
    
    
    private static func getTheUserAuthorization() {
        
        let neededParameters = [ParametersConstants.oauthToken]
        
        let arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        
        let urlUserAuthorization = concatenateUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfOauthParameters, isBaseString: false)
        
        guard let url = URL(string: urlUserAuthorization) else {return}
        
        let safariView = SFSafariViewController(url: url)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(safariView, animated: true, completion: nil)
    }
    
    
    private static func exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: String, completion: @escaping (_ token: String, _ secretToken: String, _ username: String, _ fullname: String, _ usernsid: String) -> ()) {
        
        let paramAfterUserAuthorization = separateResponce(stringToSplit: callBackAfterUserAuthorization)
        
        guard paramAfterUserAuthorization.keys.contains("oauth_token") else {return print("error token")}
            oauthToken = paramAfterUserAuthorization["oauth_token"]
       
        guard paramAfterUserAuthorization.keys.contains("oauth_verifier") else {return print("error verifier")}
            oauthVerifier = paramAfterUserAuthorization["oauth_verifier"]
        
        let neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthVerifier, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthToken]
        
        let urlRequestAccess = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.accessTokenUrl)
        
        getResponseFromUrl(link: urlRequestAccess) { result in
            
            let response = self.separateResponce(stringToSplit: result)
            
            guard response.keys.contains("oauth_token_secret") else {return print("error AccessSecretToken")}
                oauthTokenSecret = response["oauth_token_secret"]
        
            guard response.keys.contains("oauth_token") else {return print("error AccessToken")}
                oauthToken = response["oauth_token"]
            
            guard response.keys.contains("username") else {return print("error username")}
                let userName = response["username"]
                UserDefaults.standard.set(userName, forKey: "username")
            
            guard response.keys.contains("fullname") else {return print("error fullname")}
                let fullName = response["fullname"]
            
            guard response.keys.contains("user_nsid") else {return print("error user_nsid")}
                let userNsid = response["user_nsid"]
        
            completion(oauthToken!, oauthTokenSecret!, userName!, fullName!, userNsid!)
        }
    }
    
    
    private static func getRequestURL(neededOauthParameters: [String], requestURL: String) -> String {
        
        var neededParameters = neededOauthParameters
        var arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        let baseString = concatenateUrlString(urlString: requestURL, parameters: arrayOfOauthParameters, isBaseString: true)
//        print(baseString)
        getSignatureFromStringWithEncodedCharact(string: baseString)
        neededParameters = [ParametersConstants.oauthSignature]
        arrayOfOauthParameters = arrayOfOauthParameters + getOauthParametersByNeededParameters(oauthParam: oauthParameters, neededParam: neededParameters)
        let urlRequest = concatenateUrlString(urlString: requestURL, parameters: arrayOfOauthParameters, isBaseString: false)
//        print(urlRequest)
        
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



