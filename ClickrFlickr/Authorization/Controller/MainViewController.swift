//
//  MainViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/14/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var partOneLabel: UILabel!
    @IBOutlet weak var partTwoLabel: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    
    var shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.cameraAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FlickrUserAuthentication.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isAuthorized()
    

    }
    
    func isAuthorized() {
        
        if FlickrUserAuthentication.getIsAuthorized() {
            performSegue(withIdentifier: "Authorized", sender: self)
        } else {
//            UIView.animate(withDuration: 50, delay: 0, options: .curveLinear, animations: {
////                self.partOneLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
////                self.labelsStackView.spacing = self.view.bounds.width
//            }) { (success) in
//                self.performSegue(withIdentifier: "NotAuthorized", sender: self)
//            }
            performSegue(withIdentifier: "NotAuthorized", sender: self)
        }
    }
    
    private func cameraAnimation() {
        
        let path = UIBezierPath()
   
        path.move(to: CGPoint(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y))
        path.addLine(to: CGPoint(x: labelsStackView.frame.origin.x , y: labelsStackView.frame.origin.y - labelsStackView.bounds.width))
        path.addLine(to: CGPoint(x: labelsStackView.frame.origin.x + labelsStackView.bounds.width, y: labelsStackView.frame.origin.y - labelsStackView.bounds.width))
        path.addLine(to: CGPoint(x: labelsStackView.frame.origin.x + labelsStackView.bounds.width, y: labelsStackView.frame.origin.y))
        path.addLine(to: CGPoint(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.path = path.cgPath
        
        view.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 2
        shapeLayer.add(animation, forKey: "MyAnimation")
        self.shapeLayer = shapeLayer
    }
    
}

extension MainViewController: FlickrUserAuthenticationDelegate {
    
    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
