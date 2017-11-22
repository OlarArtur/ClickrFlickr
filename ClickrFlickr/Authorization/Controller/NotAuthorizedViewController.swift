//
//  ViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/5/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SpriteKit


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
        clickrFlickrLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        pleaseAuthorizeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        authorizeButton.layer.cornerRadius = 15
        animateBackground()
    }
    
    func animateBackground() {
        
        let backgroundView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 2053, height: 1460))
        backgroundView.layer.zPosition = -20
        backgroundView.image = UIImage(named: "background.jpg")
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.95
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        view.addSubview(backgroundView)
        
        UIView.animate(withDuration: 100.0, delay: 0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            backgroundView.frame.origin.x = -(backgroundView.frame.width - self.view.frame.width)
        }, completion: nil)
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

