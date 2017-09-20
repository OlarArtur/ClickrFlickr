//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices


class AuthorizedViewController: UIViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tagsText: UITextField!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBAction func logOut(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "tokensecret")
        let safariView = SFSafariViewController(url: URL(string: Constants.logOutURL)!, entersReaderIfAvailable: true)
        present(safariView, animated: true, completion: nil)
        safariView.delegate = self
    }

    @IBAction func search(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameObject = UserDefaults.standard.object(forKey: "username")
        if let name = nameObject as? String {
            userName.text = name
        }
        CallingFlickrAPIwithOauth.getDataJSON()
    }
    
    
}
