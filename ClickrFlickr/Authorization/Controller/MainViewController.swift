//
//  MainViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/14/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var partOneLabel: UILabel!
    @IBOutlet weak var partTwoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAuthorized()
        FlickrUserAuthentication.delegate = self
    }
    
    func isAuthorized() {
        
        if FlickrUserAuthentication.getIsAuthorized() {
            performSegue(withIdentifier: "Authorized", sender: self)
        } else {
            performSegue(withIdentifier: "NotAuthorized", sender: self)
        }
    }
    
}

extension MainViewController: FlickrUserAuthenticationDelegate {
    
    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
