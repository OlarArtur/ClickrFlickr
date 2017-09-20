//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices


class TestViewController: UIViewController, SFSafariViewControllerDelegate {
    

    @IBAction func logOut(_ sender: UIButton) {
        
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "tokensecret")
        let safariView = SFSafariViewController(url: URL(string: "https://www.flickr.com/logout.gne")!, entersReaderIfAvailable: true)
        present(safariView, animated: true, completion: nil)
        safariView.delegate = self
    }
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameObject = UserDefaults.standard.object(forKey: "username")
        if let name = nameObject as? String {
            userName.text = name
        }
        CallingFlickrAPIwithOauth.getJSON()
    }

    
    deinit {
        print("TestViewController is dsinit")
    }
    
}
