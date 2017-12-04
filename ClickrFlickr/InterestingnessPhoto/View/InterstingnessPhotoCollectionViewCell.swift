//
//  InterstingnessPhotoCollectionViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class InterstingnessPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with photo: Photo) {
        self.photo.image = photo.image
        self.descriptionLabel.text = photo.description
        self.titleLabel.text = photo.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
    }
}
