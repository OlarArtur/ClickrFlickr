//
//  MainNavigationController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FlickrUserAuthentication.delegate = self
        isAuthorized()
    }
    
    func isAuthorized() {
        
        if FlickrUserAuthentication.getIsAuthorized() {
            performSegue(withIdentifier: "Authorized", sender: self)
        }
    }
    
}

extension MainNavigationController: FlickrUserAuthenticationDelegate {

    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
