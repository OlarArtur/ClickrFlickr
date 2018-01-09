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
    
    func configure(with title: String, _ photo: UIImage?) {
        self.photo.image = photo
        self.titlePhoto.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
        self.titlePhoto.text = ""
    }
    
}
