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
        let lensLayer = CAShapeLayer()
        
        let centerLayerFrame = CGRect(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y - labelsStackView.bounds.width / 2 , width: labelsStackView.bounds.width, height: labelsStackView.bounds.width / 2)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock ({
            photoCameraLayer.removeFromSuperlayer()
            lensLayer.removeFromSuperlayer()
            self.animateOvals()
        })
        
        photoCameraLayer.frame = centerLayerFrame
        photoCameraLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        photoCameraLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        photoCameraLayer.lineWidth = 3
        photoCameraLayer.path = photoCameraPath().cgPath
        view.layer.addSublayer(photoCameraLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = photoCameraLayer.strokeStart
        animation.toValue = photoCameraLayer.strokeEnd
        animation.duration = 1.5
        animation.beginTime = 0

        lensLayer.frame = centerLayerFrame
        lensLayer.strokeColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        lensLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        lensLayer.lineWidth = 3
        lensLayer.path = lensPath().cgPath
        view.layer.addSublayer(lensLayer)
        
        let animation1 = CABasicAnimation(keyPath: "strokeEnd")
        animation1.fromValue = lensLayer.strokeStart
        animation1.toValue = lensLayer.strokeEnd
        animation1.duration = 1.5
        lensLayer.add(animation1, forKey: nil)
        
        let animation2 = CABasicAnimation(keyPath: "transform.scale")
        animation2.fromValue = 1
        animation2.toValue = 0
        animation2.duration = 0.5
        animation2.beginTime = animation.duration
        
        let animation3 = CABasicAnimation(keyPath: "transform.scale")
        animation3.fromValue = 1
        animation3.toValue = 0
        animation3.duration = 0.5
        animation3.beginTime = animation.duration
        
         let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animation, animation2]
        groupAnimation.duration = animation.duration + animation2.duration
        photoCameraLayer.add(groupAnimation, forKey: nil)
        
        let groupAnimation1 = CAAnimationGroup()
        groupAnimation1.animations = [animation1, animation3]
        groupAnimation1.duration = animation.duration + animation2.duration
        lensLayer.add(groupAnimation1, forKey: nil)
        
        CATransaction.commit()
    }
    
    private func animateOvals() {
        
        let redOval = CAShapeLayer()
        let blueOval = CAShapeLayer()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock ({
            self.performSegue(withIdentifier: "NotAuthorized", sender: self)
            redOval.removeFromSuperlayer()
            blueOval.removeFromSuperlayer()
        })
        
        let centerLayerFrame = CGRect(x: labelsStackView.frame.origin.x, y: labelsStackView.frame.origin.y - labelsStackView.bounds.width / 2 , width: labelsStackView.bounds.width, height: labelsStackView.bounds.width / 2)
        
        redOval.frame = centerLayerFrame
        blueOval.frame = centerLayerFrame
        
        redOval.fillColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        redOval.path = lensPath().cgPath
        view.layer.addSublayer(redOval)
        
        blueOval.fillColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
        blueOval.path = lensPath().cgPath
        view.layer.insertSublayer(blueOval, below: redOval)
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.5
        animation.beginTime = 0.0
        
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 0
        animation1.toValue = 1
        animation1.duration = 0.5
        animation1.beginTime = 0.0
        
        let animation2 = CABasicAnimation(keyPath: "position.x")
        animation2.fromValue = redOval.position.x
        animation2.toValue = redOval.position.x + labelsStackView.bounds.width / 3.5
        animation2.beginTime = animation.beginTime + animation.duration + 0.3
        animation2.fillMode = kCAFillModeForwards
        animation2.duration = 0.5
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animation, animation2]
        groupAnimation.duration = animation.duration + animation2.duration + 0.3
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        redOval.add(groupAnimation, forKey: nil)
        
        let animation3 = CABasicAnimation(keyPath: "position.x")
        animation3.fromValue = blueOval.position.x
        animation3.toValue = blueOval.position.x - labelsStackView.bounds.width / 3.5
        animation3.beginTime = animation1.beginTime + animation1.duration + 0.3
        animation3.fillMode = kCAFillModeForwards
        animation3.duration = 0.5
        
        let groupAnimation1 = CAAnimationGroup()
        groupAnimation1.animations = [animation1, animation3]
        groupAnimation1.duration = animation.duration + animation2.duration + 0.3
        groupAnimation1.isRemovedOnCompletion = false
        groupAnimation1.fillMode = kCAFillModeForwards
        blueOval.add(groupAnimation1, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    private func photoCameraPath() -> UIBezierPath {
        
        let widthPath = labelsStackView.frame.width
        let heightPath = widthPath / 2
        let beginPath = CGPoint(x: 0, y: heightPath)
        
        let photoCameraPath = UIBezierPath()
        photoCameraPath.move(to: beginPath)
        photoCameraPath.addLine(to: CGPoint(x: 0 , y: 0))
        
        photoCameraPath.addLine(to: CGPoint(x: widthPath * 0.2, y: 0))
        photoCameraPath.addLine(to: CGPoint(x: widthPath * 0.4, y: -15))
        photoCameraPath.addLine(to: CGPoint(x: widthPath * 0.6, y: -15))
        photoCameraPath.addLine(to: CGPoint(x: widthPath * 0.8, y: 0))
        photoCameraPath.addLine(to: CGPoint(x: widthPath, y: 0))
        
        photoCameraPath.addLine(to: CGPoint(x: widthPath, y: beginPath.y))
        photoCameraPath.addLine(to: CGPoint(x: 0, y: beginPath.y))
        
        photoCameraPath.close()
        
        return photoCameraPath
    }
    
    private func lensPath() -> UIBezierPath {
        
        let widthPath = labelsStackView.frame.width
        let heightPath = widthPath / 2
        let beginPath = CGPoint(x: 0, y: heightPath)
    
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: beginPath.x + widthPath / 2, y: beginPath.y - heightPath / 2 - 5), radius: widthPath / 4, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        ovalPath.close()
        
        return ovalPath
    }
    
}

extension MainViewController: FlickrUserAuthenticationDelegate {
    
    func didFinishAuthorize() {
        self.isAuthorized()
    }
}
