//
//  UserAuthentication.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import SafariServices


protocol UserAuthenticationDelegate: class {
    func didFinishAuthorize()
}

class UserAuthentication: CreateRequestAndGetResponse {

    static weak var delegate: UserAuthenticationDelegate?

    private static var apiKey: String?
    private static var apiSecretKey: String?
    private static var oauthCallback: String?

    private static var oauthToken: String?
    private static var oauthVerifier: String?
    private static var oauthTokenSecret: String?

    private static var isAuthorized: Bool {
        let nameObject = UserDefaults.standard.object(forKey: "fullname")
        if let _ = nameObject {
            return true
        } else {
            return false
        }
    }

    private class func oauthParameters(oauthSignature: String?) -> [String: String] {

        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))

        var dictionary = [ParametersConstants.oauthNonce: oauthNonce,
            ParametersConstants.oauthTimestamp: oauthTimestamp,
            ParametersConstants.oauthSignatureMethod: Constants.signatureMethod,
            ParametersConstants.oauthVersion: Constants.version]

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

        if let oauthCallback = UserAuthentication.oauthCallback {
            dictionary[ParametersConstants.oauthCallback] = oauthCallback
        }

        return dictionary
    }

    class func configureDataAPI(apiKey: String, apiSecretKey: String, callback: String) {

        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.oauthCallback = callback
    }

    class func takeURLScheme(url: URL) -> Bool {

        if url.scheme == Constants.urlScheme {
            
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)

            let callBackAfterUserAuthorization = url.absoluteString

            exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: callBackAfterUserAuthorization, completion: { (token, secretToken, username, fullname, usernsid) in
                delegate?.didFinishAuthorize()
            })

            return true
        } else {
            return false
        }
    }

    class func getIsAuthorized() -> Bool {
        if isAuthorized {
            return true
        } else {
            return false
        }
    }

    class func authorize() {

        oauthTokenSecret = nil

        getRequestToken() { (token, secretToken) in
            getTheUserAuthorization()
        }
    }

    private static func getRequestToken(completion: @escaping (_ token: String, _ secretToken: String) -> ()) {

        let neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthCallback, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp]

        let urlRequestToken = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.requestTokenUrl)

        getResponseFromUrl(link: urlRequestToken) { (data, result) in

            let response = self.separateResponce(stringToSplit: result)

            guard let oauthTokenSecret = response["oauth_token_secret"] else {
                completion("error", "requestSecretToken is empty")
                return
            }
            self.oauthTokenSecret = oauthTokenSecret

            guard let oauthToken = response["oauth_token"] else {
                completion("requestToken is empty", "error")
                return
            }
            self.oauthToken = oauthToken

            completion(oauthTokenSecret, oauthToken)
        }
    }

    private static func getTheUserAuthorization() {

        let neededParameters = [ParametersConstants.oauthToken]

        let arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: nil), neededParam: neededParameters)

        let urlUserAuthorization = concatenateRequestUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfOauthParameters)

        guard let url = URL(string: urlUserAuthorization) else {
            print("Error get URL from urlUserAuthorization")
            return
        }
        let safariView = SFSafariViewController(url: url)
        UIApplication.shared.keyWindow?.rootViewController?.present(safariView, animated: true, completion: nil)
    }

    private static func exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: String, completion: @escaping (_ token: String, _ secretToken: String, _ username: String, _ fullname: String, _ usernsid: String) -> ()) {

        let paramAfterUserAuthorization = separateResponce(stringToSplit: callBackAfterUserAuthorization)

        guard paramAfterUserAuthorization.keys.contains("oauth_token") else {
            print("error token after user auththorization")
            return
        }
        oauthToken = paramAfterUserAuthorization["oauth_token"]

        guard paramAfterUserAuthorization.keys.contains("oauth_verifier") else {
            print("error verifier after user auththorization")
            return
        }
        oauthVerifier = paramAfterUserAuthorization["oauth_verifier"]

        let neededParameters = [ParametersConstants.oauthNonce, ParametersConstants.oauthVerifier, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthToken]

        let urlRequestAccess = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.accessTokenUrl)

        getResponseFromUrl(link: urlRequestAccess) { (data, result) in

            let response = self.separateResponce(stringToSplit: result)

            guard let tokenSecret = response["oauth_token_secret"] else {
                print("error AccessSecretToken")
                return
            }
            self.oauthTokenSecret = tokenSecret

            guard let token = response["oauth_token"] else {
                print("error AccessToken")
                return
            }
            self.oauthToken = token

            guard let userName = response["username"] else {
                print("error access username")
                return
            }

            guard let fullName = response["fullname"] else {
                print("error access fullname")
                return
            }

            guard let userNsid = response["user_nsid"] else {
                print("error access user_nsid")
                return
            }
            UserDefaults.standard.set(tokenSecret, forKey: "tokensecret")
            UserDefaults.standard.set(token, forKey: "token")
            UserDefaults.standard.set(fullName, forKey: "fullname")
            completion(token, tokenSecret, userName, fullName, userNsid)
        }
    }

    private static func getRequestURL(neededOauthParameters: [String], requestURL: String) -> String {

        var neededParameters = neededOauthParameters
        var arrayOfOauthParameters = getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: nil), neededParam: neededParameters)
        let baseString = concatenateBaseUrlString(urlString: requestURL, parameters: arrayOfOauthParameters)

        guard let apiSecretKey = apiSecretKey else {
            print("ERROR get requestToken: apiSecretKey is empty")
            return "ERROR get requestToken: apiSecretKey is empty"
        }

        guard let baseStringCurrent = baseString else {
            print("ERROR baseString")
            return "ERROR baseString"
        }

        let oauthSignature = getSignatureFromStringWithEncodedCharact(string: baseStringCurrent, apiSecretKey: apiSecretKey, tokenSecret: oauthTokenSecret)

        neededParameters = [ParametersConstants.oauthSignature]
        arrayOfOauthParameters = arrayOfOauthParameters + getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: oauthSignature), neededParam: neededParameters)
        let urlRequest = concatenateRequestUrlString(urlString: requestURL, parameters: arrayOfOauthParameters)

        return urlRequest
    }

}

