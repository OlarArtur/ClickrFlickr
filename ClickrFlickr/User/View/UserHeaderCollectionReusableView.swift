//
//  UserHeaderCollectionReusableView.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/29/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class UserHeaderCollectionReusableView: UICollectionReusableView {
    
    var userInfo: UserInfo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        userInfo = UserInfo()
        userInfo.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userInfo)
        userInfo.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        userInfo.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        userInfo.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        userInfo.heightAnchor.constraint(equalToConstant: 180).isActive = true
        userInfo.fullNameLabel.text = ""
        userInfo.userNameLabel.text = ""
        userInfo.photoCountLabel.text = ""
        
    }
    
    func configerUserInfo(userInfo: UserInfo) {
        self.userInfo.fullNameLabel.text = userInfo.fullNameLabel.text
        self.userInfo.userNameLabel.text = userInfo.userNameLabel.text
        self.userInfo.photoCountLabel.text = userInfo.photoCountLabel.text
        self.userInfo.avatarImageView.image = userInfo.avatarImageView.image
    }
    
}
