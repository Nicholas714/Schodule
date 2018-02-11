//
//  SchooleManager+Watch.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchConnectivity
import WatchKit

extension SchooduleManager {
    
    func updateComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let complications = complicationServer.activeComplications {
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
    
    
    
}
