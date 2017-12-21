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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            logoAnimation()
        }
    }
    
    private func logoAnimation() {
        
        let shapeLayer = CAShapeLayer()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock ({
            self.performSegue(withIdentifier: "NotAuthorized", sender: self)
            shapeLayer.removeFromSuperlayer()
        })
        
        let path = UIBezierPath()
        
        let beginPath = CGPoint(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y)
        let widthPath = labelsStackView.bounds.width
        let heightPath = widthPath / 2
   
        path.move(to: beginPath)
        path.addLine(to: CGPoint(x: beginPath.x , y: beginPath.y - heightPath))
        
        path.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.2, y: beginPath.y - heightPath))
        path.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.4, y: beginPath.y - heightPath - 15))
        path.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.6, y: beginPath.y - heightPath - 15))
        path.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.8, y: beginPath.y - heightPath))
        path.addLine(to: CGPoint(x: beginPath.x + widthPath, y: beginPath.y - heightPath))
        
        path.addLine(to: CGPoint(x: beginPath.x + widthPath, y: beginPath.y))
        path.addLine(to: CGPoint(x: beginPath.x, y: beginPath.y))
        
        path.move(to: CGPoint(x: beginPath.x + widthPath / 4, y: beginPath.y - heightPath / 2 - 5))
        path.addArc(withCenter: CGPoint(x: beginPath.x + widthPath / 2, y: beginPath.y - heightPath / 2 - 5), radius: widthPath / 4, startAngle: CGFloat.pi, endAngle: CGFloat.pi*4, clockwise: true)
        
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.path = path.cgPath
        
        view.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 3
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        CATransaction.commit()
    }
    
}

extension MainViewController: FlickrUserAuthenticationDelegate {
    
    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
