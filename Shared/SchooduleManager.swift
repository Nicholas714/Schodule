//
//  SchooduleManager.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/11/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import WatchConnectivity

class SchooduleManager {
    
    static var shared = SchooduleManager()
    
    let schoodule = Schoodule()
    var session: WCSession? = nil
    
    private init() { }
    
    func startSession(delegate: WCSessionDelegate) {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = delegate
            session?.activate()
        }
    }
    
}
