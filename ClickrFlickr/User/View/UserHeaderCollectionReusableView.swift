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
        let centerX = userInfo.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let centerY = userInfo.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        let height = userInfo.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20)
        let width = userInfo.widthAnchor.constraint(equalTo: userInfo.heightAnchor)
        NSLayoutConstraint.activate([centerX, centerY, height, width])
        
        userInfo.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        userInfo.layer.cornerRadius = 20
        userInfo.layer.shadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        userInfo.layer.shadowOpacity = 0.8
        userInfo.layer.shadowRadius = 4
        userInfo.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        userInfo.fullNameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        userInfo.userNameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
