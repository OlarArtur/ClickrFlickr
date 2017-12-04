//
//  OnlyPhotoViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/30/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class OnlyPhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    func configure(with photo: Photo) {
        self.photo.image = photo.image
        print(self.bounds)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
    }
}
