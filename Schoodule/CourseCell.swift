//
//  CourseCell.swift
//  Schoodule
//
//  Created by Nicholas Grana on 8/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseTime: UILabel!
    @IBOutlet weak var courseTeacher: UILabel!
    @IBOutlet weak var courseLocation: UILabel!
    
    var course: Course? {
        didSet {
            guard let course = course else {
                return
            }
            
            gradientView.setGradient(course.gradient)
            courseName.text = course.name
            courseTime.text = course.timeframe.title
            courseTeacher.text = course.instructor
            courseLocation.text = course.location
        }
    }
    
}
