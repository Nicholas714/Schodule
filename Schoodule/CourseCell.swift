//
//  CourseCell.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseStartTime: UILabel!
    @IBOutlet weak var courseEndTime: UILabel!
    @IBOutlet weak var courseTeacher: UILabel!
    @IBOutlet weak var courseLocation: UILabel!
    
    var course: Course? {
        didSet {
            guard let course = course else {
                return
            }
            
            courseName.text = course.name
            courseStartTime.text = course.event.startDate.timeString
            courseEndTime.text = course.event.endDate.timeString
            courseTeacher.text = course.event.notes ?? ""
            courseLocation.text = course.event.location ?? ""
        }
    }
    
}
