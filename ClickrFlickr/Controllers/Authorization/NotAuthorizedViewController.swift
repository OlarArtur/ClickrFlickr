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
    
    @IBOutlet weak var clickrLabel: UILabel!
    @IBOutlet weak var flickrLabel: UILabel!
    @IBOutlet weak var pleaseAuthorizeLabel: UILabel!
    @IBOutlet weak var authorizeButton: UIButton!
    
    private var authBackgroundView: UIImageView!
    
    @IBAction func authorize(_ sender: UIButton) {
        sender.pulsate()
        FlickrUserAuthentication.authorize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authBackgroundView.removeFromSuperview()
        view.layer.removeAllAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeButton.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        createBackground()
        animateBackground()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pleaseAuthorizeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setupAuthorizeButton()
        
    }
    
    private func setupAuthorizeButton() {
        authorizeButton.layer.cornerRadius = 8
        authorizeButton.layer.shadowOpacity = 0.6
        authorizeButton.layer.shadowRadius = 3
        authorizeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        authorizeButton.applyGradient(topGradientColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), bottomGradientColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    }
    
    private func createBackground() {
        
        authBackgroundView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 2053, height: 1460))
        
        authBackgroundView.image = UIImage(named: "background.jpg")
        self.view.insertSubview(authBackgroundView, at: 0)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.95
        blurEffectView.frame = authBackgroundView.bounds
        authBackgroundView.addSubview(blurEffectView)
        
    }
    
    private func animateBackground() {
        guard let authBackgroundView = authBackgroundView else {return}
        UIView.animate(withDuration: 100.0, delay: 0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            authBackgroundView.frame.origin.x = self.view.bounds.size.width - authBackgroundView.frame.width
            }, completion: nil)
    }
    
}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 1
        pulse.toValue = 0.9
        self.layer.add(pulse, forKey: "pulse")
        
    }
    
    func applyGradient(topGradientColor: UIColor, bottomGradientColor: UIColor) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.cornerRadius = self.layer.cornerRadius
        gradient.frame = self.bounds
        gradient.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
        gradient.locations = [0, 1]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}

