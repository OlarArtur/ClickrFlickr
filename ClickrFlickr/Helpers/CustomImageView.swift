//
//  CustomImageView.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/26/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import UIKit


class CustomImageView: UIImageView {
    
    func loadImageUsingUrlString (urlString: String, completion: @escaping (UIImage) ->()) {
        
        guard let url = URL(string: urlString) else {return}
    
        NetworkServise.shared.getData(url: url) { (data) in

            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {return}
                completion(image)
            }
        }
    }
    
}
