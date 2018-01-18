//
//  DetailPhotoViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class DetailPhotoViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    func configer(image: UIImage) {
        self.photoImage.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImage.image = nil
    }

}
