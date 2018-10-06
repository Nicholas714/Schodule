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

    func applicationDidFinishLaunching(_ application: UIApplication) {
        EventStore.reloadYear()
    }

}

