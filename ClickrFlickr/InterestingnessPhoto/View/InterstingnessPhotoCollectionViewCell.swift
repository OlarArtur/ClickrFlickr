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
        makeCellAppearance()
        
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
    
    private func makeCellAppearance() {
        guard let htmlString = self.descriptionLabel.text else {return}
        guard let htmlData = htmlString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {return}
        guard let attributedString = try? NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {return}
        self.descriptionLabel.text = attributedString.string
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if isOnlyPhoto {
            self.photo.image = UIImage()
        } else {
            self.titleLabel.text = String()
            self.photo.image = UIImage()
            self.descriptionLabel.text = String()
        }
    }
    
}
