//
//  ConnectivityController.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 9/25/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchConnectivity

class ConnectivityController: NSObject {
    
    var session: WCSession? = nil

    func sendRefreshRequest(type: String, replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        session?.sendMessage(["message": type], replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendRefresh(finished: @escaping () -> ()) {
        if WCSession.isSupported() && session == nil {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        sendRefreshRequest(type: "refreshRequest", replyHandler: { (period) in
            print("watch: i got it")
            let pastScheduleList = ExtensionDelegate.storage.scheduleList
            
            let decoder = JSONDecoder()

            if let schedules = try? decoder.decode(ScheduleList.self, from: period["courses"] as! Data) {
                ExtensionDelegate.storage.scheduleList = schedules
            }
            
            if ExtensionDelegate.storage.scheduleList.schedules != pastScheduleList.schedules {
                ExtensionDelegate.storage.saveSchedule()
                DispatchQueue.main.async {
                    print("asyc create table")
                    finished()
                }
                ExtensionDelegate.updateComplications()
            }
        })
    }
    
}

extension ConnectivityController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}
