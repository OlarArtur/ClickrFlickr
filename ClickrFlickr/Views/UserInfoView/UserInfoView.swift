//
//  UserInfoView.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 1/5/18.
//  Copyright © 2018 Artur Olar. All rights reserved.
//

import UIKit

@IBDesignable class UserInfoView: UIView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var photoCountLabel: UILabel!
    
    @IBOutlet weak var topStackView: UIStackView!
    
    @IBInspectable var avatar: UIImage {
        get {
            return avatarImageView.image!
        }
        set(avatar) {
            avatarImageView.image = avatar
        }
    }
    
    @IBInspectable var userName: String {
        get {
            return userNameLabel.text!
        }
        set(userName) {
            userNameLabel.text = userName
        }
    }
    
    @IBInspectable var fullName: String {
        get {
            return fullNameLabel.text!
        }
        set(fullName) {
            userNameLabel.text = fullName
        }
    }
    
    @IBInspectable var photoCount: String {
        get {
            return photoCountLabel.text!
        }
        set(photoCount) {
            userNameLabel.text = photoCount
        }
    }
    
    var view: UIView!
    var nibName: String = "UserInfo"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func loadFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    private func setup() {
        view = loadFromNib()
        avatarImageView.layer.cornerRadius = 10
        avatarImageView.layer.masksToBounds = true
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
        
    }
    
    
}

