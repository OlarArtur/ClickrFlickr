//
//  MainSegue.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/14/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class MainSegue: UIStoryboardSegue {
    
    override func perform() {
        scale()
    }
    
    private func scale() {
        
        let toViewController = self.destination
        let fromViewController = self.source
        
        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toViewController.view.center = fromViewController.view.center
        
        fromViewController.view.superview?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform.identity
        }) { success in
            fromViewController.present(toViewController, animated: false, completion: nil)
        }
    }

}
