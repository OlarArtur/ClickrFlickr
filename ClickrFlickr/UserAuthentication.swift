//
//  UserAuthentication.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation



extension String {
    func hmac(algorithm: Encryption.HMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}

class Encryption {
    
    enum HMACAlgorithm {
        case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
        
        func toCCHmacAlgorithm() -> CCHmacAlgorithm {
            var result: Int = 0
            switch self {
            case .MD5:
                result = kCCHmacAlgMD5
            case .SHA1:
                result = kCCHmacAlgSHA1
            case .SHA224:
                result = kCCHmacAlgSHA224
            case .SHA256:
                result = kCCHmacAlgSHA256
            case .SHA384:
                result = kCCHmacAlgSHA384
            case .SHA512:
                result = kCCHmacAlgSHA512
            }
            return CCHmacAlgorithm(result)
        }
        
        func digestLength() -> Int {
            var result: CInt = 0
            switch self {
            case .MD5:
                result = CC_MD5_DIGEST_LENGTH
            case .SHA1:
                result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:
                result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:
                result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:
                result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:
                result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }
}



struct Constants {
    static let signatureMethod: String = "HMAC-SHA1"
    static let version: String = "1.0"
    static let requestTokenUrl = "https://www.flickr.com/services/oauth/request_token?"
    static let authorizeUrl = "https://www.flickr.com/services/oauth/authorize?"
    static let accessTokenUrl = "https://www.flickr.com/services/oauth/access_token?"
}


class  UserAuthentication {
    
    private var apiKey: String
    private var apiSecretKey: String
    private var callback: String
    
    private var signature: String?
    
    private var token: String?
    private var verifier: String?
    private var tokenSecret: String?
    
    
    init(apiKey: String, apiSecretKey: String, callback: String) {
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.callback = callback
    }
    
    private var consumerKey: String {
        return apiKey
    }
    
    private var oauthNonce: String {
        return "oauth_nonce=\(arc4random_uniform(99999999) + 10000000)"
    }
    
    //    private func getNonce() -> String {
    //        let nonce = String(arc4random_uniform(99999999) + 10000000)
    //        return nonce
    //    }
    
    private var oauthTimestamp: String {
        return "oauth_timestamp=\(String(Int(NSDate().timeIntervalSince1970)))"
    }
    
    private var oauthConsumerKey: String {
        return "oauth_consumer_key=\(consumerKey)"
    }
    
    private var oauthSignatureMethod: String {
        return "oauth_signature_method=\(Constants.signatureMethod)"
    }
    
    private var oauthVersion: String {
        return "oauth_version=\(Constants.version)"
    }
    
    private var oauthCallback: String {
        return "oauth_callback=\(callback)"
    }
    
    private var oauthSignature: String? {
        guard let signature = signature  else {
            preconditionFailure("signature is empty")
        }
        return "oauth_signature=\(signature)"
    }
    
    private var oauthToken: String? {
        guard let token = token  else {
            preconditionFailure("oauthToken is empty")
        }
        return "oauth_token=\(token)"
    }
    
    private var oauthVerifier: String? {
        guard let verifier = verifier  else {
            preconditionFailure("verifier is empty")
        }
        return "oauth_verifier=\(verifier)"
    }
    
    private var oauthTokenSecret: String? {
        guard let tokenSecret = tokenSecret  else {
            preconditionFailure("tokenSecret is empty")
        }
        return "oauth_token_secret=\(tokenSecret)"
    }
    
    
    func authorize() {
        
        //        1.Get a Request Token
        //        2.Get the User's Authorization
        //        2.Exchange the Request Token for an Access Token
        
        getRequestToken()
        getTheUserAuthorization()
        exchangeRequestTokenForAccessToken()
        
    }
    
    private func getRequestToken() {
        
        var arrayOfParameters = [oauthNonce, oauthCallback, oauthVersion, oauthSignatureMethod, oauthConsumerKey, oauthTimestamp]
        
        let baseString = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfParameters, isBaseString: true)
        
        getSignatureFromStringWithEncodedCharact(string: baseString)
        
        arrayOfParameters += [oauthSignature!]
        let urlRequestToken = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfParameters, isBaseString: false)
        
        let dataString = getResponseFromUrl(url: urlRequestToken)
        
        let response = separateResponce(stringToSplit: dataString)
        
        if response.keys.contains("oauth_token_secret") {
            tokenSecret = response["oauth_token_secret"]
        }
        
        if response.keys.contains("oauth_token") {
            token = response["oauth_token"]
        }
        
    }
    
    private func getTheUserAuthorization() {
        
        let urlUserAuthorization = concatenateUrlString(urlString: Constants.authorizeUrl, parameters: [oauthToken!], isBaseString: false)
        print(urlUserAuthorization)
        
        
    }
    
    private func exchangeRequestTokenForAccessToken() {
        
    }
    
    
    private func getUrlPartWithSortedParameters(arrayOfParameters: [String]) -> String {
        
        let sortedArray = arrayOfParameters.sorted()
        let stringFromArray = sortedArray.joined(separator: "&")
        return stringFromArray
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
    
    
    private func getSignatureFromStringWithEncodedCharact(string: String) {
        
        var key: String
        
        if tokenSecret != nil {
            key = "\(apiSecretKey)&\(tokenSecret!)"
        } else {
            key = "\(apiSecretKey)&"
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        signature = string.hmac(algorithm:Encryption.HMACAlgorithm.SHA1, key: key)
        signature = signature?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        
    }
    
    private func getResponseFromUrl(url: String) -> String {
        
        let url = URL(string: url)!
        var dataString = ""
        do {
            let data = try Data(contentsOf: url)
            dataString = String(data: data, encoding: String.Encoding.utf8)!
        } catch {
            print("errror")
        }
        return dataString
    }
    
    private func separateResponce(stringToSplit: String) -> [String: String] {
        
//        If "?"
        
        
        
        var result = [String:String]()
//        let separators = CharacterSet(charactersIn: "?&")
        let array = stringToSplit.components(separatedBy: "&")
        for element in array {
            let array = element.components(separatedBy: "=")
            result[array[0]] = array[1]
        }
        return result
        
    }
    
    
    
    
    
}



