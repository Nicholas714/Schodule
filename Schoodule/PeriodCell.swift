//
//  PeriodCell.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class PeriodCell: FoldingCell {
    static var index = 0
    
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var className: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var containerButtons: [UIButton]!
    @IBOutlet var seperator: UIView!
    
    @IBAction func toggleDay(_ sender: UIButton) {
        //sender.layer.borderWidth = 3
        //sender.layer.borderColor = UIColor.white.cgColor
        
        if let currentBackground = sender.backgroundColor, currentBackground == containerBackground {
            UIView.animate(withDuration: 0.2) {
                sender.setTitleColor(self.containerBackground, for: .normal)
                sender.backgroundColor = UIColor.white
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                sender.backgroundColor = self.containerBackground
                sender.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    var i: Int = 0
    
    var containerBackground: UIColor {
        return Array(UIColor.themes.values)[i % 10]
    }
    
    override func awakeFromNib() {
        i = PeriodCell.index
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true

        let period = SchooduleManager.shared.schoodule.periods[i]
        
        indexLabel.text = "\(PeriodCell.index + 1)"
        indexLabel.textColor = containerBackground
        className.textColor = containerBackground
        timeLabel.textColor = UIColor.white
        className.text = period.className
        timeLabel.text = "\(period.start.string) - \(period.end.string)"
        seperator.backgroundColor = containerBackground
        
        foregroundView.backgroundColor = UIColor.black
        containerView.backgroundColor = UIColor.black
        
        for button in containerButtons {
            button.setTitleColor(containerBackground, for: .normal)
            //button.layer.cornerRadius = button.frame.height / 2
            // button.clipsToBounds = true
            
            if button.currentTitle == "Mon" {
                let path = UIBezierPath(roundedRect: button.bounds,
                                        byRoundingCorners:[.bottomLeft, .topLeft],
                                        cornerRadii: CGSize(width: button.frame.height / 2, height:  button.frame.height / 2))
                
                let maskLayer = CAShapeLayer()
                
                maskLayer.path = path.cgPath
                button.layer.mask = maskLayer
            } else if button.currentTitle == "Sun" {
                let path = UIBezierPath(roundedRect: button.bounds,
                                        byRoundingCorners:[.bottomRight, .topRight],
                                        cornerRadii: CGSize(width: button.frame.height / 2, height:  button.frame.height / 2))
                
                let maskLayer = CAShapeLayer()
                
                maskLayer.path = path.cgPath
                button.layer.mask = maskLayer
            }
            
        }
        
        PeriodCell.index += 1
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}

// MARK: - Actions ⚡️

extension PeriodCell {
    
    @IBAction func buttonHandler(_: AnyObject) {
        print("tap")
    }
}

