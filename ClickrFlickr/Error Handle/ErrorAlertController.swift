//
//  ErrorAlertController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/26/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation
import UIKit


class ErrorAlertController: UIAlertController{

    func showErrorAlertController(title: String, message: String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertTryAgain = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alert.addAction(alertTryAgain)
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
    
}
