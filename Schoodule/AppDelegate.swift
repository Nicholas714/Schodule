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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if MainTableViewController.storage == nil {
            MainTableViewController.storage = Storage(defaults: UserDefaults())
        }
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
}
