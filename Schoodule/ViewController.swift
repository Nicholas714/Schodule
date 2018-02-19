//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity
import Crashlytics

class MainTableViewController: UITableViewController {
    
    @IBOutlet var scheduleTableView: UITableView!
    lazy var schoodule: Schoodule = {
        SchooduleManager.shared.startSession(delegate: self)
        return SchooduleManager.shared.schoodule
    }()
    
    @IBAction func click(_ sender: Any) {
        print("hi")
        if let period = schoodule.classFrom(date: Date()) {
            schoodule.replace(old: schoodule.unsortedPeriods.index(of: period), with: Period(className: "\(period.className)!", themeIndex: 0, start: period.start, end: period.end))
        }
        
        saveSchedule()
        
        SchooduleManager.shared.session?.transferCurrentComplicationUserInfo(schoodule.transfer)
    }
    @IBAction func renameCurrent(_ sender: UIBarButtonItem) {
        
        
    }
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadScheudle()
        SchooduleManager.shared.startSession(delegate: self)
        
        scheduleTableView.separatorStyle = .none
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoodule.periods.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.frame = CGRect.zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusePeriod", for: indexPath)
        
        cell.selectionStyle = .none
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = cell.contentView.frame.height / 2
        cell.contentView.backgroundColor = schoodule.periods[indexPath.row].color
        cell.textLabel?.text = schoodule.periods[indexPath.row].className
        cell.textLabel?.backgroundColor = UIColor.clear
        
        return cell
    }
    
}

extension MainTableViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String, message == "refreshRequest" {
            replyHandler(schoodule.transfer)
        } else if let message = message["message"] as? String, message == "complicationRefreshRequest" {
            print("sending back complication refresh...")
            session.transferCurrentComplicationUserInfo(schoodule.transfer)
        } else if let message = message["message"] as? String, message == "clear" {
            schoodule.clear()
            saveSchedule()
            
            replyHandler(schoodule.transfer)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else if let data = message["periods"] as? Data {
            schoodule.storage.decodePeriods(from: data)
            saveSchedule()
            
            replyHandler(schoodule.transfer)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    
}
