//
//  CalendarEventCell
//  Schoodule
//
//  Created by Nicholas Grana on 8/1/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventCell: UITableViewCell {
    
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseStartTime: UILabel!
    @IBOutlet weak var courseEndTime: UILabel!
    @IBOutlet weak var courseTeacher: UILabel!
    @IBOutlet weak var courseLocation: UILabel!
    @IBOutlet weak private var eventBackgroundView: UIView! {
        didSet {
            color = randomColor
        }
    }
    
    var selectionCompletionHandler: (() -> ())? = nil
    
    private lazy var randomColor: Color = {
        return Color.randomBackground
    }()
    
    var color: Color {
        get {
            return course?.color ?? randomColor
        }
        set {
            eventBackgroundView.backgroundColor = UIColor(color: newValue)
        }
    }
    
    var course: Course? {
        didSet {
            guard let course = course else {
                return
            }
            
            event = course.event
            color = course.color
        }
    }
    
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
    
    @IBAction func selected(_ sender: UITapGestureRecognizer) {
        if let handler = selectionCompletionHandler {
            handler()
        }
    }
    
}
