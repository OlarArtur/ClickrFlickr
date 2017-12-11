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
    
    override func didMoveToWindow() {
        makeCellAppearance()
    }
    
    func configure(with photoEntitie: PhotoEntitie, image: UIImage) {
        
        self.titleLabel.text = photoEntitie.title
        self.photo.image = image
        self.descriptionLabel.text =  photoEntitie.photoDescription
        
        makeCellAppearance()
        
    }
    
    func configerOnlePhoto (image: UIImage) {
        self.photo.image = image
        self.photo.contentMode = .scaleAspectFit
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
        
    }
    
    private func makeCellAppearance() {
        
        guard let htmlString = self.descriptionLabel.text else {return}
        guard let htmlData = htmlString.data(using: String.Encoding.utf8, allowLossyConversion: false) else {return}
        guard let attributedString = try? NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {return}
        self.descriptionLabel.text = attributedString.string

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.photo.image = nil
        self.descriptionLabel.text = ""
        self.titleLabel.text = ""
    }
    
}
