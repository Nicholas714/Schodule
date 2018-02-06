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
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
    
        let period = MainTableViewController.schoodule.periods[PeriodCell.index]
        
        indexLabel.text = "\(PeriodCell.index + 1)"
        className.text = period.className
        timeLabel.text = period.start.string
        
        foregroundView.backgroundColor = Array(UIColor.themes.values)[PeriodCell.index % 10]
        containerView.backgroundColor = Array(UIColor.themes.values)[PeriodCell.index % 10]
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

