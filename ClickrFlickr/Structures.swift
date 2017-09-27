//
//  Structures.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


struct Constants {
    static let signatureMethod: String = "HMAC-SHA1"
    static let version: String = "1.0"
    static let requestTokenUrl: String = "https://www.flickr.com/services/oauth/request_token?"
    static let authorizeUrl: String = "https://www.flickr.com/services/oauth/authorize?"
    static let accessTokenUrl: String = "https://www.flickr.com/services/oauth/access_token?"
    static let apiRequestUrl: String = "https://api.flickr.com/services/rest?"
    static let logOutURL: String = "https://www.flickr.com/logout.gne"
    static let urlScheme = "clickrflickr"
    static let format = "json"
    static let noJsonCallback = "1"
    static let methodPhotosSearch = "flickr.photos.search"
}


struct ParametersConstants {
    static let oauthTags: String = "tags"
    static let oauthMethod: String = "method"
    static let oauthFormat: String = "format"
    static let oauthNoJsonCallback: String = "nojsoncallback"
    
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

struct NeededParametersForRequest {
    
    static let getRequestToken: [String] = [ParametersConstants.oauthNonce, ParametersConstants.oauthCallback, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp]
    
    static let getUserAuthorization: [String] = [ParametersConstants.oauthToken]
    
    static let exchangeRequestTokenForAccessToken: [String] = [ParametersConstants.oauthNonce, ParametersConstants.oauthVerifier, ParametersConstants.oauthVersion, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthToken]
    
    static let callingFlickrMethodPhotosSearch: [String] = [ParametersConstants.oauthMethod, ParametersConstants.oauthConsumerKey, ParametersConstants.oauthTimestamp, ParametersConstants.oauthFormat, ParametersConstants.oauthNoJsonCallback, ParametersConstants.oauthToken, ParametersConstants.oauthNonce, ParametersConstants.oauthSignatureMethod, ParametersConstants.oauthVersion, ParametersConstants.oauthTags]
}
