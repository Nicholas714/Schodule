//
//  ScheduleHeaderView.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/9/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class ScheduleHeaderView: UIView {
    
    @IBOutlet var scheduleHeaderTitle: UILabel!
    @IBOutlet var scheduleHeaderSubtitle: UILabel!
    
    var schedule: Schedule? {
        didSet {
            if let schedule = self.schedule {
                scheduleHeaderTitle.text = schedule.title
                scheduleHeaderSubtitle.text = schedule.scheduleType.subtitle
            } else {
                scheduleHeaderTitle.text = "Today"
                scheduleHeaderSubtitle.text = Date().dayString
            }
        }
    }
    
}

