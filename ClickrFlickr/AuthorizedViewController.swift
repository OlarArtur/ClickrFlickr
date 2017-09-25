//
//  TestViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices


protocol AuthorizedViewControllerDelegate: class {

    func fillPhotoData(photoData: Data)
}

class AuthorizedViewController: UIViewController, SFSafariViewControllerDelegate {

    static weak var delegate: AuthorizedViewControllerDelegate?

    var arrayPhotosData = [[String: String]]()

    @IBOutlet weak var tagsText: UITextField!

    @IBOutlet weak var userName: UILabel!

    @IBAction func search(_ sender: UIButton) {

        guard let text = tagsText.text else { return }

        CallingFlickrAPIwithOauth.getDataJSON(oauthTags: text) { (data) in
            AuthorizedViewController.delegate?.fillPhotoData(photoData: data)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutPressed))

        let nameObject = UserDefaults.standard.object(forKey: "fullname")
        if let name = nameObject as? String {
            userName.text = name.removingPercentEncoding
        }
    }

    func logOutPressed() {
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "tokensecret")

        let safariView = SFSafariViewController(url: URL(string: Constants.logOutURL)!, entersReaderIfAvailable: true)
        present(safariView, animated: true, completion: nil)
        safariView.delegate = self
        navigationController?.popToRootViewController(animated: true)
    }


}
