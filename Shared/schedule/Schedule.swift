//
//  Schedule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 5/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

struct Schedule {
    
    var periods = [Period]()
    var dateframe: Dateframe
    
    var isToday: Bool {
        // TODO: check constraints and between date frame
        return true
    }
    
}
