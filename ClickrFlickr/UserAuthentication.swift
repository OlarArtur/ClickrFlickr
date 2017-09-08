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
    static let requestTokenUrl: String = "https://www.flickr.com/services/oauth/request_token?"
    static let authorizeUrl: String = "https://www.flickr.com/services/oauth/authorize?"
    static let accessTokenUrl: String = "https://www.flickr.com/services/oauth/access_token?"
}


struct ParametersConstants {
    
    static let oauthNonce: String = "oauth_nonce="
    static let oauthTimestamp: String = "oauth_timestamp="
    static let oauthConsumerKey: String = "oauth_consumer_key="
    static let oauthSignatureMethod: String = "oauth_signature_method="
    static let oauthVersion: String = "oauth_version="
    static let oauthCallback: String = "oauth_callback="
    static let oauthSignature: String = "oauth_signature="
    static let oauthToken: String = "oauth_token="
    static let oauthVerifier: String = "oauth_verifier="
    static let oauthTokenSecret: String = "oauth_token_secret="
}


class  UserAuthentication {
    
    private var oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
    private var oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))
    
    private var apiKey: String
    private var apiSecretKey: String
    private var oauthCallback: String
    
    private var oauthSignature: String?
    private var oauthToken: String?
    private var oauthVerifier: String?
    private var oauthTokenSecret: String?
    
    init(apiKey: String, apiSecretKey: String, callback: String) {
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.oauthCallback = callback
    }
    
    private var oauthConsumerKey: String {
        return apiKey
    }
    
    private var oauthParameters: [String : String]? {
        return initParameters()
    }
    
    func initParameters () -> [String : String] {
        let dictionary = [ParametersConstants.oauthSignature : oauthSignature,
                          ParametersConstants.oauthToken : oauthToken,
                          ParametersConstants.oauthCallback : oauthCallback,
                          ParametersConstants.oauthTokenSecret : oauthTokenSecret,
                          ParametersConstants.oauthVerifier : oauthVerifier,
                          ParametersConstants.oauthConsumerKey : oauthConsumerKey,
                          ParametersConstants.oauthNonce : oauthNonce,
                          ParametersConstants.oauthTimestamp : oauthTimestamp,
                          ParametersConstants.oauthSignatureMethod : Constants.signatureMethod,
                          ParametersConstants.oauthVersion : Constants.version]
        var parameters = [String : String]()
        for (key, value) in dictionary {
            if let value = value {
                parameters[key] = value
            }
        }
        return parameters
    }
    
    
    func authorize() {
        
        //        1.Get a Request Token
        //        2.Get the User's Authorization
        //        3.Exchange the Request Token for an Access Token
        
        getRequestToken()
        getTheUserAuthorization()
        exchangeRequestTokenForAccessToken()
        
    }
    
    
    private func getRequestToken() {
        
        var oauthParameters = self.oauthParameters
        
        var neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthCallback, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp]
        
        var arrayOfParameters = getNeededParametersFromOauthParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
        
        let baseString = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfParameters, isBaseString: true)
        
        getSignatureFromStringWithEncodedCharact(string: baseString)
        
        neededParameters.append(ParametersConstants.oauthSignature)
        oauthParameters?[ParametersConstants.oauthSignature] = self.oauthParameters?[ParametersConstants.oauthSignature]
        
        arrayOfParameters = getNeededParametersFromOauthParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
        
        let urlRequestToken = concatenateUrlString(urlString: Constants.requestTokenUrl, parameters: arrayOfParameters, isBaseString: false)
        print(urlRequestToken)
        
        let dataString = getResponseFromUrl(url: urlRequestToken)
        print(dataString)
        
        let response = separateResponce(stringToSplit: dataString)
        
        if response.keys.contains("oauth_token_secret") {
            oauthTokenSecret = response["oauth_token_secret"]
        }
        
        if response.keys.contains("oauth_token") {
            oauthToken = response["oauth_token"]
        }
        
    }
    
    
    
    
    private func getNeededParametersFromOauthParameters(oauthParam: [String:String], neededParam: [String]) -> [String] {
        
        var resultArray = [String]()
        
        for (key, value) in oauthParam {
            for fuck in neededParam {
                if fuck == key {
                    let stringSum = "\(key)\(value)"
                    resultArray.append(stringSum)
                }
            }
        }
        return resultArray
    }
    
    
    
    private func getTheUserAuthorization() {
            
        let oauthParameters = self.oauthParameters
            
        let neededParameters = [ParametersConstants.oauthToken]
            
        let arrayOfParameters = getNeededParametersFromOauthParameters(oauthParam: oauthParameters!, neededParam: neededParameters)
    
        let urlUserAuthorization = concatenateUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfParameters, isBaseString: false)
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
        
        if oauthTokenSecret != nil {
            key = "\(apiSecretKey)&\(oauthTokenSecret!)"
        } else {
            key = "\(apiSecretKey)&"
        }
        
        let customAllowedSet = CharacterSet(charactersIn: "=+/").inverted
        
        oauthSignature = string.hmac(algorithm:Encryption.HMACAlgorithm.SHA1, key: key)
        oauthSignature = oauthSignature!.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        
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



