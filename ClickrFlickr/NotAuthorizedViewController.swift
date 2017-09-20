//
//  ViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit



class NotAuthorizedVieController: UIViewController {
    
    
    @IBAction func authorize(_ sender: UIButton) {
        UserAuthentication.authorize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("ViewController is deinit")
    }
    
    
}

