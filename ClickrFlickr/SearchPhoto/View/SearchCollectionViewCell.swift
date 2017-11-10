//
//  SearchCollectionViewCell.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class SearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var titlePhoto: UILabel!
    @IBOutlet weak var spinnerActivityIndicator: UIActivityIndicatorView!
    
    func configure(with photo: Photo) {
        self.photo.image = photo.image
        self.titlePhoto.text = photo.title
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.layer.cornerRadius = 10.0
//        layer.borderWidth = 0.5
//    }
    
}
