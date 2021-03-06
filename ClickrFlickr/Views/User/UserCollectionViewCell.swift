//
//  UserCollectionViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    var titlePhoto: UILabel!
    var photo: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addViews() {
        titlePhoto = UILabel()
        addSubview(titlePhoto)
        
        photo = UIImageView()
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.contentMode = .scaleAspectFit
        addSubview(photo)
        photo.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        photo.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        photo.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        photo.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        self.titlePhoto.text = nil
    }
    
}

