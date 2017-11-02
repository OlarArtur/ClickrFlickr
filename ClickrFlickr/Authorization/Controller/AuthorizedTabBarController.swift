//
//  AuthorizedTabBarController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices

class AuthorizedTabBarController: UITabBarController, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutPressed))
    }
    
    func logOutPressed() {
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "tokensecret")
        
        guard let url = URL(string: Constants.logOutURL) else {
            let error = ErrorAlertController()
            error.showErrorAlertController(title: "Error! LogOut URL", message: "Try again?")
            return
        }
        let safariView = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        present(safariView, animated: true, completion: nil)
        safariView.delegate = self
        navigationController?.popToRootViewController(animated: true)
    }
    
}
