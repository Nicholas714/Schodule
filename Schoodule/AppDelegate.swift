//
//  AppDelegate.swift
//  Schoodule
//
//  Created by Nicholas Grana on 7/19/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        EventStore.reloadYear {
            if let nav = self.window?.rootViewController as? UINavigationController {
                if let top = nav.topViewController as? Actable {
                    top.didBecomeActive()
                }
            }
        }
    }

}

