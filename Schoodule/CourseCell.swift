//
//  CourseCell.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseStartTime: UILabel!
    @IBOutlet weak var courseEndTime: UILabel!
    @IBOutlet weak var courseTeacher: UILabel!
    @IBOutlet weak var courseLocation: UILabel!
    
    var event: EKEvent? {
        didSet {
            guard let event = event else {
                return
            }
            
            courseName.text = event.title 
            courseStartTime.text = event.startDate.timeString
            courseEndTime.text = event.endDate.timeString
            courseTeacher.text = event.notes ?? ""
            courseLocation.text = event.location ?? ""
        }
    }
    
}
