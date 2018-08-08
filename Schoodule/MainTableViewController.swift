//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity

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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ClassCreateSegue":
            if let destination = segue.destination as? ClassCreateController {
                destination.scheduleList = storage.scheduleList

                if let indexPath = tableView.indexPathForSelectedRow {
                    let scheduleIndex = indexPath.section - 1
                    let courseIndex = indexPath.row
                    
                    if scheduleIndex == -1 {
                        let entry = storage.scheduleList.todayCourseEntries[courseIndex]
                        destination.initialCourse = entry.0
                        destination.initialSchedule = entry.1
                    } else {
                        destination.initialSchedule = storage.scheduleList.schedules[scheduleIndex]
                        destination.initialCourse = destination.initialSchedule!.classList[courseIndex]
                    }
                }
            }
        default:
            return
        }
        
    }
    
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        storage.scheduleList = ScheduleList()
        tableView.reloadData()
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return storage.scheduleList.todayCourses.isEmpty ? "No Classes Today" : nil
        case 1:
            return storage.scheduleList.schedules.isEmpty ? "No Schedules" : storage.scheduleList.schedules[section - 1].title
        case _:
            return storage.scheduleList.schedules[section - 1].title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")! as! CourseCell
        
        let course: Course
        if indexPath.section == 0 {
            course = storage.scheduleList.todayCourses[indexPath.row]
        } else {
            course = storage.scheduleList.schedules[indexPath.section - 1].classList[indexPath.row]
        }
        
        cell.course = course
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return storage.scheduleList.schedules.isEmpty ? 2 : storage.scheduleList.schedules.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return storage.scheduleList.todayCourses.count
        case _:
            return storage.scheduleList.schedules.isEmpty ? 0 : storage.scheduleList.schedules[section - 1].classList.count
        }
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
