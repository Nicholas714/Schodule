//
//  ExtensionDelegate.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/4/18.
//  Copyright © 2018 Schoodule. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    private static var todayEvents: [Event]?
    
    static func getTodayEvents() -> [Event] {
        return todayEvents ?? [Event]()
    }
    
    static func reloadTodayEvents() {
        todayEvents = storage.schedule.todayEvents
    }
    
    var root: InterfaceController? {
        return WKExtension.shared().rootInterfaceController as? InterfaceController
    }
    
    static var storage = Storage(defaults: UserDefaults())
    static var connectivityController = ConnectivityController()
    
    func applicationDidFinishLaunching() {
        ExtensionDelegate.connectivityController.sendRefresh {
            self.root?.createTable()
        }
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // this is called before snapshotTask is carried out automatically, so no need to schedule it
                ExtensionDelegate.updateComplications()
                backgroundTask.setTaskCompletedWithSnapshot(false)
                print("BACKGROUND TASK HAS RAN")
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                
                if snapshotTask.reasonForSnapshot == .appBackgrounded || snapshotTask.reasonForSnapshot == .appScheduled {
                    print("app was went to the background, update complications")
                    ExtensionDelegate.updateComplications()
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
    
    static func updateComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let complications = complicationServer.activeComplications {
            
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
            print("watch: updating complications")
        }
    }
    
}

