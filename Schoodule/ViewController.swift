//
//  ViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    let schoodule = Schoodule(fake: true)
    var session: WCSession!
    
    @IBOutlet var encodeLabel: UILabel!
        
    @IBAction func sendSchedule(_ sender: UIButton) {
        print("sending")
        session.sendMessageData(schoodule.storage.encodePeriods()!, replyHandler: { (data) in
            print("reply ios")
        }, errorHandler: { (error) in
            print("error ios")
        })
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        schoodule.storage.decodePeriods(from: messageData)
        schoodule.storage.saveSchedule()
        print("recieved")
        
        encodeLabel.text = schoodule.periods.map({ (period) -> String in
            return "\(period.className), "
        }).description
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoodule.storage.loadScheudle()
        
        encodeLabel.text = schoodule.periods.map({ (period) -> String in
            return "\(period.className), "
        }).description
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

