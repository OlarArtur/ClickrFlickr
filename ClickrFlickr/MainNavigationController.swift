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

        UserAuthentication.delegate = self
        isAuthorized()
    }
    
    func isAuthorized() {
        
        if UserAuthentication.getIsAuthorized() {
            performSegue(withIdentifier: "Authorized", sender: self)
        }
    }
    
}

extension MainNavigationController: UserAuthenticationDelegate {

    func didFinishAuthorize() {
        DispatchQueue.main.async() {
            self.isAuthorized()
        }
    }
}
