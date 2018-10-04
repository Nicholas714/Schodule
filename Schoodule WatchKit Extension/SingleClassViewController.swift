//
//  SingleClassViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 9/24/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit

class SingleClassViewController: WKInterfaceController {
    
    @IBOutlet weak var eventName: WKInterfaceLabel!
    @IBOutlet weak var eventTimeframe: WKInterfaceLabel!
    @IBOutlet weak var eventLocation: WKInterfaceLabel!
    
    var event: Event! {
        didSet {
            eventName.setText(event.name)
            eventName.setTextColor(UIColor(color: event.color))
            
            eventTimeframe.setText("\(event.startDate.timeString) – \(event.endDate.timeString)")
            
            if event.location.isEmpty {
                eventLocation.setHidden(true)
            } else {
                eventLocation.setHidden(false)
                eventLocation.setText(event.location)
            }
            
        }
    }
    
    override func awake(withContext context: Any?) {
        self.event = context as? Event
    }
    
}

