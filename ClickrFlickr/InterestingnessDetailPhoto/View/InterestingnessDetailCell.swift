//
//  InterestingnessDetailCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/24/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class InterestingnessDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    var photo: Photo!
    
    func configure(with photo: Photo) {
        self.photoImage.image = photo.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImage.image = nil
    }
    
}
