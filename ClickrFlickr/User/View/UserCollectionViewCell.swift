//
//  UserCollectionViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titlePhoto: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    func configure(with photo: Photo) {
        self.photo.image = photo.image
        self.titlePhoto.text = photo.title
    }
    
}
