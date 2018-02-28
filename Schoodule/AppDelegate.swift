//
//  AppDelegate.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    var root: MainTableViewController? {
        return (window?.rootViewController as? UINavigationController)?.topViewController as? MainTableViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SchooduleManager.shared.startSession(delegate: self)
        SchooduleManager.shared.loadScheudle()
        Fabric.with([Crashlytics.self])
        
        return true
    }
}

extension AppDelegate: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String, message == "refreshRequest" {
            replyHandler(schoodule.transfer)
        } else if let message = message["message"] as? String, message == "clear" {
            schoodule.clear()
            SchooduleManager.shared.saveSchedule()
            
            replyHandler(schoodule.transfer)
            
            DispatchQueue.main.async {
                self.root?.tableView.reloadData()
            }
            
        } else if let data = message["periods"] as? Data {
            schoodule.storage.decodePeriods(from: data)
            SchooduleManager.shared.saveSchedule()
                        
            replyHandler(schoodule.transfer)
            
            DispatchQueue.main.async {
                self.root?.tableView.reloadData()
            }
        }
    }
}

