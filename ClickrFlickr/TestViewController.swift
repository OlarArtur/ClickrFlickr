//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

//extension TestViewController: DetailViewControllerDelegate {
//    func didFinishTask(sender: UserAuthentication) {
//        // do stuff like updating the UI
//    }
//}

class TestViewController: UIViewController, DetailViewControllerDelegate {
    
    
//    var userAuthentication: UserAuthentication?
    

    @IBAction func logOut(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "username")
        URLCache.shared.removeAllCachedResponses()
    }
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserAuthentication.delegate = self
        
        let nameObject = UserDefaults.standard.object(forKey: "username")
        if let name = nameObject as? String {
            userName.text = name
        }
    }
    
    func didFinishTask() {
        print("hello")
        DispatchQueue.main.async() {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
