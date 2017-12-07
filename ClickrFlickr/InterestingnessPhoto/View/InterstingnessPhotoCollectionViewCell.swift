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
        
        self.photo.image = image
        self.descriptionLabel.text = photoEntitie.photoDescription
        self.titleLabel.text = photoEntitie.title
        
        makeAppearanceViews()
        
    }
    
    func configerOnlePhoto (image: UIImage) {
        self.photo.image = image
        self.photo.contentMode = .scaleAspectFit
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
        
    }
    
    private func makeAppearanceViews() {
        
        self.photo.layer.shadowRadius = 2
        self.photo.layer.shadowOpacity = 0.8
        self.descriptionLabel.layer.shadowOpacity = 0.8
        self.descriptionLabel.layer.shadowRadius = 2
        self.titleLabel.layer.shadowOpacity = 0.8
        self.titleLabel.layer.shadowRadius = 2
        
        guard let description = self.descriptionLabel.text else {return}
        if let htmlData = description.data(using: String.Encoding.utf16, allowLossyConversion: false) {
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            
            guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {return}
            self.descriptionLabel.text = attributedString.string
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
    }
    
}
