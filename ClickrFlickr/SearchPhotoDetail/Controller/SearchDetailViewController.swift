//
//  SearchDetailViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 10/30/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class SearchDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let photo = photo else {return}
        CustomImageView.loadImageUsingUrlString(urlString: photo.url) { (image) in
            self.detailImageView.image = image
        }
        
        print(photo.owner)
    }


}
