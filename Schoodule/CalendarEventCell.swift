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
    @IBOutlet weak private var eventBackgroundView: UIView!
    
    var selectionCompletionHandler: (() -> ())? = nil
    
    var entry: BubbleEntry? {
        didSet {
            guard let entry = entry else {
                return
            }
            
            entry.populateCell(eventCell: self)
        }
    }
    
    var color: Color = Color.unselected {
        didSet {
            eventBackgroundView.backgroundColor = UIColor(color: color)
        }
    }
        
    @IBAction func selected(_ sender: UITapGestureRecognizer) {
        if let handler = selectionCompletionHandler {
            handler()
        }
    }
    
}
