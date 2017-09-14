//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class TestViewController: UIViewController{
    
    
    var userAuthentication: UserAuthentication?
    

    @IBAction func logOut(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "username")
    }
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameObject = UserDefaults.standard.object(forKey: "username")
        if let name = nameObject as? String {
            userName.text = name
        }
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
