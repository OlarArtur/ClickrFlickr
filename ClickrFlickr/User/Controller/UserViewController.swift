//
//  UserViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nameObject = UserDefaults.standard.object(forKey: "fullname")
        if let name = nameObject as? String {
            userNameLabel.text = name.removingPercentEncoding
        }
    }

    
}
