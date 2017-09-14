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

    isAuthorized()
        
    }
    
    
    func finishAuth(){
        performSegue(withIdentifier: "Authorized", sender: self)
    }
    
    
    func isAuthorized(){
        if UserAuthentication.getIsAuthorized(){
            performSegue(withIdentifier: "Authorized", sender: self)
        } else {
            performSegue(withIdentifier: "Not authorized", sender: self)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
