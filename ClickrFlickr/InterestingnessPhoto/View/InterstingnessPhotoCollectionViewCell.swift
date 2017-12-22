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
    
    private var isOnlyPhoto: Bool = false
    
    func configure(with photoEntitie: PhotoEntitie, image: UIImage?) {
        isOnlyPhoto = false
        self.titleLabel.text = photoEntitie.title
        self.descriptionLabel.text =  photoEntitie.photoDescription
        
        self.titleLabel.alpha = 1
        self.descriptionLabel.alpha = 1
        self.photo.contentMode = .scaleToFill
        guard let image = image else {return}
        self.photo.image = image
    }
    
    func configerOnlyPhoto (image: UIImage) {
        isOnlyPhoto = true
        
        self.titleLabel.alpha = 0
        self.descriptionLabel.alpha = 0
        
        self.photo.image = image
        self.photo.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        if !isOnlyPhoto {
            self.titleLabel.text = ""
            self.descriptionLabel.text = ""
        }
    }
    
}
