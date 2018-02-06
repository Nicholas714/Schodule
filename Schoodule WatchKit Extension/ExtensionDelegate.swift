//
//  ExtensionDelegate.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var session: WCSession? = nil
    var schoodule: Schoodule! = nil
    
    func createNextRefresh() {
        let nextUpdate = Date().addingTimeInterval(30)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextUpdate, userInfo: nil) { (error) in }
    }
    
    func createTable() {
        (WKExtension.shared().rootInterfaceController as? InterfaceController)?.createTable()
    }
    
    func startSession() {
        if WCSession.isSupported() && session == nil {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func applicationDidFinishLaunching() {
        schoodule = Schoodule()
        
        startSession()
        
        // start refresh cycle
        createNextRefresh()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            // called to update timeline
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                let complicationServer = CLKComplicationServer.sharedInstance()
                
                if let complications = complicationServer.activeComplications {
                    for complication in complications {
                        complicationServer.reloadTimeline(for: complication)
                    }
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
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.schoodule.storage.decodePeriods(from: applicationContext["periods"] as! Data)
        
        DispatchQueue.main.async {
            self.createTable()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil || activationState == .notActivated {
            (WKExtension.shared().rootInterfaceController as? InterfaceController)?.showError()
            return
        }
        
        session.sendMessage(["message": "refreshRequest"], replyHandler: { (period) in
            self.schoodule.storage.decodePeriods(from: period["periods"] as! Data)
            
            DispatchQueue.main.async {
                self.createTable()
            }
            
        }) { (error) in
            print(error)
        }
    }

}
