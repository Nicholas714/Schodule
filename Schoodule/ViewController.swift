//
//  ViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    var session: WCSession?
    
    let schoodule = Schoodule(fake: true)
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    @IBOutlet var encodeLabel: UILabel!

    var transfer: [String: Data] {
        return ["periods": schoodule.storage.encoded]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScheudle()
        
        encodeLabel.text = schoodule.periods.map({ (period) -> String in
            return "\(period.className), "
        }).description
        
        startSession()
    }

    func saveSchedule() {
       defaults.setValue(schoodule.storage.encoded, forKey: "periods")
    }
    
    func loadScheudle() {
        schoodule.unsortedPeriods.removeAll()
        
        if let data = defaults.value(forKey: "periods") as? Data {
            let decoder = JSONDecoder()
            
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    schoodule.unsortedPeriods.append(period)
                }
            } catch {
                fatalError("Error decoding periods.")
            }
        }
    }

    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // TODO: call when objects are edited
    func tryUpdate() {
        do {
            try session?.updateApplicationContext(transfer)
        } catch {
            
        }
    }
}

extension ViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String, message == "refreshRequest" {
            replyHandler(transfer)
        } else if let data = message["periods"] as? Data {
            schoodule.storage.decodePeriods(from: data)
            saveSchedule()
            
            encodeLabel.text = schoodule.periods.map({ (period) -> String in
                return "\(period.className), "
            }).description
            
            replyHandler(transfer)
        }
    }
    
}
