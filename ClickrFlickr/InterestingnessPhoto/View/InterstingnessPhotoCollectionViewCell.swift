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
        
        self.titleLabel.isHidden = false
        self.descriptionLabel.isHidden = false
        self.photo.contentMode = .scaleToFill
        guard let image = image else {return}
        self.photo.image = image
    }
    
    func configerOnlyPhoto (image: UIImage) {
        isOnlyPhoto = true
        
        self.titleLabel.isHidden = true
        self.descriptionLabel.isHidden = true
        
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
