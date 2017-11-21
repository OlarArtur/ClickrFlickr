//
//  ViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class NotAuthorizedViewController: UIViewController {
    
    @IBOutlet weak var clickrFlickrLabel: UILabel!
    @IBOutlet weak var pleaseAuthorizeLabel: UILabel!
    @IBOutlet weak var authorizeButton: UIButton!
    
    @IBAction func authorize(_ sender: UIButton) {
        sender.pulsate()
        FlickrUserAuthentication.authorize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeButton.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        clickrFlickrLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        pleaseAuthorizeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        authorizeButton.layer.cornerRadius = 15
    }
    
}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
}

