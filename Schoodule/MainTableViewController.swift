//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity
import EventKit
import EventKitUI

class MainTableViewController: UITableViewController {
    
    var storage = Storage(defaults: UserDefaults())
    var session: WCSession? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if WCSession.isSupported() && session == nil {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        tableView.reloadData()
        
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.isTranslucent = true 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CalendarEventListViewController":
            if let destination = segue.destination as? CalendarEventListViewController {
                destination.storage = storage
            }
        default:
            return
        }
        
    }
    
    @IBAction func addNewEvent(_ sender: UIBarButtonItem) {
        let editEventViewController = EKEventEditViewController()
        editEventViewController.event = EKEvent(eventStore: EKEventStore())
        editEventViewController.editViewDelegate = self
        self.present(editEventViewController, animated: true, completion: nil)
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")! as! CourseCell
        
        cell.course = storage.schedule.todayCourses[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storage.schedule.todayCourses.count
    }
    
}

extension MainTableViewController: WCSessionDelegate {
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String, message == "refreshRequest" {
            replyHandler(storage.transfer)
        } else if let message = message["message"] as? String, message == "clear" {
            storage.saveSchedule()
            
            replyHandler(storage.transfer)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else if let _ = message["courses"] as? Data {
            print("iPhone: you requested, sending back")
            storage.saveSchedule()
            
            replyHandler(storage.transfer)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension MainTableViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        print(action.rawValue)
    }
    
}
