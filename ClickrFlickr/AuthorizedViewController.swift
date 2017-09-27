//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class AuthorizedViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nameObject = UserDefaults.standard.object(forKey: "fullname")
        if let name = nameObject as? String {
            userName.text = name.removingPercentEncoding
        }
    }

}
