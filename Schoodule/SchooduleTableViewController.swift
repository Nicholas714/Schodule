//
//  SchooduleTableViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity

class SchooduleTableViewController: UITableViewController {

    // MARK: WatchConnectivity Support
    
    var session: WCSession?
    
    var schoodule = Schoodule()
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    var transfer: [String: Data] {
        return ["periods": schoodule.storage.encoded]
    }
    
    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
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
    
    // TODO: call when objects are edited
    func tryUpdate() {
        do {
            try session?.updateApplicationContext(transfer)
        } catch {
            
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScheudle()
        startSession()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoodule.periods.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusePeriod", for: indexPath)

        cell.textLabel?.text = "\(schoodule.periods[indexPath.row].className)"
        
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            schoodule.removePeriod(index: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

}

extension SchooduleTableViewController: WCSessionDelegate {
    
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
            
            replyHandler(transfer)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}
