//
//  ExtensionDelegate.swift
//  Schodule WatchKit Extension
//
//  Created by Nicholas Grana on 9/13/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // set next update for every 2 hours
    func createNextRefresh() {
        let nextUpdate = Date().addingTimeInterval(7200)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextUpdate, userInfo: nil) { (error) in }
    }
    
    func applicationDidFinishLaunching() {
        // start refresh cycle
        createNextRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            // called to update timeline
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let complicationServer = CLKComplicationServer.sharedInstance()
                
                for complication in complicationServer.activeComplications! {
                    complicationServer.reloadTimeline(for: complication)
                }
                
                // call in another 2 hours
                createNextRefresh()
                
                backgroundTask.setTaskCompletedWithSnapshot(false)
            default:
                // called by system
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
