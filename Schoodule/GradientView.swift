//
//  GradientView.swift
//
//  Created by Mathieu Vandeginste on 06/12/2016.
//  Copyright © 2018 Mathieu Vandeginste. All rights reserved.
//
import UIKit

@IBDesignable class GradientView: UIView {
    
    private var gradientLayer: CAGradientLayer!
    
    @IBInspectable var topColor: UIColor = .red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = .yellow {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowX: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowY: CGFloat = -3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var startPointY: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var endPointX: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var endPointY: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var cornerRadiuss: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func setGradient(_ gradient: Gradient) {
        self.topColor = gradient.darkColor
        self.bottomColor = gradient.lightColor
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func draw(_ rect: CGRect) {
        self.gradientLayer = self.layer as? CAGradientLayer
        self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        self.layer.cornerRadius = cornerRadiuss
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
        self.layer.shadowRadius = shadowBlur
        self.layer.shadowOpacity = 1
    }
    
//    override func layoutSubviews() {
//        self.gradientLayer = self.layer as! CAGradientLayer
//        self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
//        self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
//        self.layer.cornerRadius = cornerRadiuss
//        self.layer.shadowColor = shadowColor.cgColor
//        self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
//        self.layer.shadowRadius = shadowBlur
//        self.layer.shadowOpacity = 1
//
//    }
    
    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
        self.gradientLayer?.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.gradientLayer?.add(animation, forKey:"animateGradient")
    }
}
