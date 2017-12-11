//
//  SearchDetailViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/11/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class SearchDetailViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    func configure(with photo: Photo) {
        self.photoImage.image = photo.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImage.image = nil
    }
    

}
