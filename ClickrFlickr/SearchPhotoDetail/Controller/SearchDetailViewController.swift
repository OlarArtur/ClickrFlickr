//
//  SearchDetailViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 10/30/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class SearchDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var userInfo: UserInfo!
    var photo: Photo?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo.fullNameLabel.text = ""
        userInfo.userNameLabel.text = ""
        userInfo.photoCountLabel.text = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let photo = photo else {return}
        CustomImageView.loadImageUsingUrlString(urlString: photo.url) { [weak self] image in
            guard let strongSelf = self else {return}
            strongSelf.detailImageView.image = image
        }
    }
    
    func configUserInfo() {
        guard let user = user else {return}
        DispatchQueue.main.async {
            self.userInfo.fullNameLabel.text = user.realName
            self.userInfo.userNameLabel.text = user.userName
            self.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
        }
        
        CustomImageView.loadImageUsingUrlString(urlString: user.urlAvatar) { [weak self] image in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                strongSelf.userInfo.avatarImageView.image = image
            }
        }
    }

}
