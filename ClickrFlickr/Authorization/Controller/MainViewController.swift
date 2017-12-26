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
        
        let photoCameraLayer = CAShapeLayer()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock ({
            self.performSegue(withIdentifier: "NotAuthorized", sender: self)
            photoCameraLayer.removeFromSuperlayer()
        })
        
        photoCameraLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        photoCameraLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        photoCameraLayer.lineWidth = 3
        photoCameraLayer.path = photoCameraPath().cgPath
        
        view.layer.addSublayer(photoCameraLayer)
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.fromValue = photoCameraLayer.strokeStart
        animation.toValue = photoCameraLayer.strokeEnd
        animation.duration = 3
        photoCameraLayer.add(animation, forKey: nil)

        let lensLayer = CAShapeLayer()
        view.layer.addSublayer(lensLayer)
        lensLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        lensLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        lensLayer.lineWidth = 3
        lensLayer.path = lensPath().cgPath
        
        let animation1 = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation1.fromValue = lensLayer.strokeStart
        animation1.toValue = lensLayer.strokeEnd
        animation1.duration = 3
        lensLayer.add(animation1, forKey: nil)
        
        CATransaction.commit()
    }
    
    private func photoCameraPath() -> UIBezierPath {
        
        let beginPath = CGPoint(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y)
        let widthPath = labelsStackView.bounds.width
        let heightPath = widthPath / 2
        
        let photoCameraPath = UIBezierPath()
        photoCameraPath.move(to: beginPath)
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x , y: beginPath.y - heightPath))
        
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.2, y: beginPath.y - heightPath))
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.4, y: beginPath.y - heightPath - 15))
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.6, y: beginPath.y - heightPath - 15))
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath * 0.8, y: beginPath.y - heightPath))
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath, y: beginPath.y - heightPath))
        
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x + widthPath, y: beginPath.y))
        photoCameraPath.addLine(to: CGPoint(x: beginPath.x, y: beginPath.y))
        
        photoCameraPath.close()
        
        return photoCameraPath
    }
    
    private func lensPath() -> UIBezierPath {
        
        let beginPath = CGPoint(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y)
        let widthPath = labelsStackView.bounds.width
        let heightPath = widthPath / 2
    
        let ovalPath = UIBezierPath()
        ovalPath.move(to: CGPoint(x: beginPath.x + widthPath / 4, y: beginPath.y - heightPath / 2 - 5))
        ovalPath.addArc(withCenter: CGPoint(x: beginPath.x + widthPath / 2, y: beginPath.y - heightPath / 2 - 5), radius: widthPath / 4, startAngle: CGFloat.pi, endAngle: CGFloat.pi*3, clockwise: true)
        ovalPath.close()
        
        return ovalPath
    }
    
}

extension MainViewController: FlickrUserAuthenticationDelegate {
    
    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
