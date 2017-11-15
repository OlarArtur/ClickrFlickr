//
//  FlickrUserAuthentication.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import SafariServices


protocol FlickrUserAuthenticationDelegate: class {
    func didFinishAuthorize()
}

class FlickrUserAuthentication {

    static weak var delegate: FlickrUserAuthenticationDelegate?

    private static var apiKey: String?
    private static var apiSecretKey: String?
    private static var oauthCallback: String?

    private static var oauthToken: String?
    private static var oauthVerifier: String?
    private static var oauthTokenSecret: String?

    private static var isAuthorized: Bool {
        let nameObject = UserDefaults.standard.object(forKey: "usernsid")
        if let _ = nameObject {
            return true
        } else {
            return false
        }
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

            do {
                try exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: callBackAfterUserAuthorization, completion: { (token, secretToken, username, fullname, usernsid) in

                    UserDefaults.standard.set(secretToken, forKey: "tokensecret")
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(fullname, forKey: "fullname")
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(usernsid, forKey: "usernsid")

                    delegate?.didFinishAuthorize()
                })
            } catch {
                let error = ErrorAlertController()
                error.showErrorAlertController(title: "Error! ExchangeRequestTokenForAccessToken", message: "Try again?")
            }
            
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

        do {
            try getRequestToken() { (token, secretToken) in
                guard let token = token, let secretToken = secretToken else {
                    return
                }
                do {
                    try getTheUserAuthorization(oauthTokenSecret: secretToken, oauthToken: token)
                } catch {
                    let error = ErrorAlertController()
                    error.showErrorAlertController(title: "ERROR! Get The User Authorization", message: "Try again?")
                }
            }
        } catch {
            let error = ErrorAlertController()
            error.showErrorAlertController(title: "Error! Token & secretToken is empty", message: "Try again?")
        }
    }

    private static func getRequestToken(completion: @escaping (_ token: String?, _ secretToken: String?) -> ()) throws {

        let neededParameters = NeededParametersForRequest.getRequestToken

        guard let urlRequestToken = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.requestTokenUrl) else { throw FlickOauthError.RequestError }

        let flickrGetResponse = FlickrGetResponse()
        flickrGetResponse.getResponseFromUrl(link: urlRequestToken) { (data, result) in

            guard let result = result else {
                completion(nil, nil)
                return
            }

            guard let response = flickrGetResponse.separateResponce(stringToSplit: result) else {
                completion(nil, nil)
                return
            }

            guard let oauthTokenSecret = response["oauth_token_secret"] else {
                completion(nil, nil)
                return
            }
            self.oauthTokenSecret = oauthTokenSecret

            guard let oauthToken = response["oauth_token"] else {
                completion(nil, nil)
                return
            }
            self.oauthToken = oauthToken
            completion(oauthTokenSecret, oauthToken)
        }
    }

    private static func getTheUserAuthorization(oauthTokenSecret: String, oauthToken: String) throws {

        let neededParameters = NeededParametersForRequest.getUserAuthorization

        let flickrCreateRequest = FlickrCreateRequest()

        let arrayOfOauthParameters = flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: nil), neededParam: neededParameters)

        let urlUserAuthorization = flickrCreateRequest.concatenateRequestUrlString(urlString: Constants.authorizeUrl, parameters: arrayOfOauthParameters)

        guard let url = URL(string: urlUserAuthorization) else {
            throw FlickOauthError.RequestError
        }
        let safariView = SFSafariViewController(url: url)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(safariView, animated: true, completion: nil)
        
    }

    private static func exchangeRequestTokenForAccessToken(callBackAfterUserAuthorization: String, completion: @escaping (_ token: String?, _ secretToken: String?, _ userName: String?, _ fullName: String?, _ userNsid: String?) -> ()) throws {

        let flickrGetResponse = FlickrGetResponse()

        guard let paramAfterUserAuthorization = flickrGetResponse.separateResponce(stringToSplit: callBackAfterUserAuthorization) else { throw FlickOauthError.ResponseError }

        guard let oauthToken = paramAfterUserAuthorization["oauth_token"] else { throw FlickOauthError.ResponseError }
        self.oauthToken = oauthToken

        guard let oauthVerifier = paramAfterUserAuthorization["oauth_verifier"] else { throw FlickOauthError.ResponseError }
        self.oauthVerifier = oauthVerifier

        let neededParameters = NeededParametersForRequest.exchangeRequestTokenForAccessToken

        guard let urlRequestAccess = getRequestURL(neededOauthParameters: neededParameters, requestURL: Constants.accessTokenUrl) else { throw FlickOauthError.ResponseError }

        flickrGetResponse.getResponseFromUrl(link: urlRequestAccess) { (data, result) in

            guard let result = result else {
                completion(nil, nil, nil, nil, nil)
                return
            }

            guard let response = flickrGetResponse.separateResponce(stringToSplit: result) else {
                completion(nil, nil, nil, nil, nil)
                return
            }

            guard let tokenSecret = response["oauth_token_secret"] else {
                completion(nil, nil, nil, nil, nil)
                return
            }

            guard let token = response["oauth_token"] else {
                completion(nil, nil, nil, nil, nil)
                return
            }

            guard let userName = response["username"] else { return }
            guard let fullName = response["fullname"] else { return }
            guard let userNsid = response["user_nsid"] else { return }

            completion(token, tokenSecret, userName, fullName, userNsid)
        }
    }

    private static func getRequestURL(neededOauthParameters: [String], requestURL: String) -> String? {

        let flickrCreateRequest = FlickrCreateRequest()

        var neededParameters = neededOauthParameters
        var arrayOfOauthParameters = flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: nil), neededParam: neededParameters)
        let baseString = flickrCreateRequest.concatenateBaseUrlString(urlString: requestURL, parameters: arrayOfOauthParameters)

        guard let apiSecretKey = apiSecretKey else {
            return nil
        }

        guard let baseStringCurrent = baseString else {
            return nil
        }

        let oauthSignature = flickrCreateRequest.getSignatureFromStringWithEncodedCharact(string: baseStringCurrent, apiSecretKey: apiSecretKey, tokenSecret: oauthTokenSecret)

        neededParameters = [ParametersConstants.oauthSignature]
        arrayOfOauthParameters = arrayOfOauthParameters + flickrCreateRequest.getOauthParametersByNeededParameters(oauthParam: oauthParameters(oauthSignature: oauthSignature), neededParam: neededParameters)
        let urlRequest = flickrCreateRequest.concatenateRequestUrlString(urlString: requestURL, parameters: arrayOfOauthParameters)

        return urlRequest
    }

    private class func oauthParameters(oauthSignature: String?) -> [String: String] {

        let oauthNonce: String = String(arc4random_uniform(99999999) + 10000000)
        let oauthTimestamp: String = String(Int(NSDate().timeIntervalSince1970))

        var dictionary = [ParametersConstants.oauthNonce: oauthNonce,
            ParametersConstants.oauthTimestamp: oauthTimestamp,
            ParametersConstants.oauthSignatureMethod: Constants.signatureMethod,
            ParametersConstants.oauthVersion: Constants.version]

        if let oauthConsumerKey = apiKey {
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

        if let oauthCallback = oauthCallback {
            dictionary[ParametersConstants.oauthCallback] = oauthCallback
        }
        return dictionary
    }

}

