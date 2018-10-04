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
            color = Color.randomBackground
        }
    }
    
    var selectionCompletionHandler: (() -> ())? = nil
    
    var entry: BubbleEntry? {
        didSet {
            guard let entry = entry else {
                return
            }
            
            entry.populateCell(eventCell: self)
        }
    }
    
    var color: Color {
        get {
            return entry?.color ?? Color.randomBackground
        }
        set {
            entry?.course.color = newValue
            entry?.color = newValue
            eventBackgroundView.backgroundColor = UIColor(color: newValue)
        }
    }
        
    @IBAction func selected(_ sender: UITapGestureRecognizer) {
        if let handler = selectionCompletionHandler {
            handler()
        }
    }
    
}
