//
//  SchooleManager+Watch.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchConnectivity
import ClockKit

extension SchooduleManager {
    
    func updateComplications() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        
        if let complications = complicationServer.activeComplications {
            
            SchooduleManager.shared.loadScheudle()
            
            for complication in complications {
                complicationServer.reloadTimeline(for: complication)
            }
        }
    }
    
    func sendClearRequest(replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        session?.sendMessage(["message" : "clear"], replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendRefreshRequest(type: String, replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        session?.sendMessage(["message": type], replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendUpdatedContents(replyHandler: (([String : Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        session?.sendMessage(["periods": schoodule.storage.encoded], replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
}
