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
    
    func configure(with photoEntitie: PhotoEntitie, image: UIImage) {
        
        self.titleLabel.text = photoEntitie.title
        self.photo.image = image
        self.descriptionLabel.text =  photoEntitie.photoDescription
        
        decodeHTMLinDescription()
        
    }
    
    func configerOnlePhoto (image: UIImage) {
        self.photo.image = image
        self.photo.contentMode = .scaleAspectFit
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
        
    }
    
    private func decodeHTMLinDescription() {
        guard let htmlString = self.descriptionLabel.text else {return}
        guard let htmlData = htmlString.data(using: String.Encoding.utf16, allowLossyConversion: false) else {return}
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {return}
        self.descriptionLabel.text = attributedString.string
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
    }
    
}
