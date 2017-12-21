//
//  String+HMAC.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/12/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

extension String {
    
    func hmac(algorithm: CCHmacAlgorithm, key: String) -> String? {
        
        guard let cKey = key.cString(using: String.Encoding.utf8) else {
            return nil
        }
        
        guard let cData = cString(using: String.Encoding.utf8) else {
            return nil
        }
        
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey, Int(strlen(cKey)), cData, Int(strlen(cData)), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(CC_SHA1_DIGEST_LENGTH)))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}
