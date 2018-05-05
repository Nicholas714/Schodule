//
//  ExtensionDelegate.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var manager = SchooduleManager.shared
    
    var schoodule: Schoodule {
        return manager.schoodule
    }
    
    var root: InterfaceController? {
        return WKExtension.shared().rootInterfaceController as? InterfaceController
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // this is called before snapshotTask is carried out automatically, so no need to schedule it
                SchooduleManager.shared.updateComplications()
                backgroundTask.setTaskCompletedWithSnapshot(false)
                print("BACKGROUND TASK HAS RAN")
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
               
                if snapshotTask.reasonForSnapshot == .appBackgrounded || snapshotTask.reasonForSnapshot == .appScheduled {
                    print("app was went to the background, update complications")
                    SchooduleManager.shared.updateComplications()
                } else {
                    // this automatically refreshes the UI
                    root?.createTable()
                }
                
                // schedules a new snapshot update in 1 hour
                snapshotTask.setTaskCompletedWithSnapshot(true)
                
                print("BACKGROUND TASK HAS RAN FOR \(root == nil ? "NIL" : "ACTUAL") ROOT")
            default:
                // called by system
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
}
