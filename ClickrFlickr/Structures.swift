//
//  Structures.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation



struct Constants {
    
    static let apiRequestUrl: String = "https://api.flickr.com/services/rest?"
    
    static let signatureMethod: String = "HMAC-SHA1"
    static let version: String = "1.0"
    static let requestTokenUrl: String = "https://www.flickr.com/services/oauth/request_token?"
    static let authorizeUrl: String = "https://www.flickr.com/services/oauth/authorize?"
    static let accessTokenUrl: String = "https://www.flickr.com/services/oauth/access_token?"
    static let urlScheme = "clickrflickr"
}


struct ParametersConstants {
    
    static let authApiKey: String = "api_key"
    static let authApiSig: String = "api_sig"
    static let authDate: String = "date"
    static let authMethod: String = "method"
    static let authFormat: String = "format"
    static let authNoJsonCallback: String = "nojsoncallback"
    
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
