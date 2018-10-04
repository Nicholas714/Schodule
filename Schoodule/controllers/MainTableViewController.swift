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

class MainTableViewController: BubbleTableViewController {
    
    var storage = Storage(defaults: UserDefaults())
    var session: WCSession? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if WCSession.isSupported() && session == nil {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        self.cellTapped = { cell in
            
        }
        
        entries = storage.schedule.todayCourses.compactMap { EventBubbleEntry(course: $0, event: $0.events.first!) }
        
        tableView.reloadData()
        
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.isTranslucent = true 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "CalendarEventListViewController":
            if let destination = segue.destination as? CalendarEventListViewController {
                print("storage set in segue")
                destination.storage = storage
            }
        default:
            return
        }
        
    }
    
    @IBAction func addNewEvent(_ sender: UIBarButtonItem) {
        let store = EKEventStore()
        
        let editEventViewController = EKEventEditViewController()
        let event = EKEvent(eventStore: store)
        editEventViewController.eventStore = store
        // TODO: change calendar to Schoodule?
        event.calendar = store.defaultCalendarForNewEvents
        editEventViewController.event = event
        editEventViewController.editViewDelegate = self
        self.present(editEventViewController, animated: true, completion: nil)
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
//        switch action {
//        case .deleted:
//            if let event = controller.event {
//                if let indexToRemove = storage.schedule.courses.firstIndex(of: Course(name: event.title)) {
//                    storage.schedule.courses.remove(at: indexToRemove)
//                    storage.saveSchedule()
//                }
//            }
//
//            controller.dismiss(animated: true, completion: nil)
//        case .saved:
//            if let event = controller.event {
//                let course = Course(name: event.title!)
//                if !storage.schedule.courses.contains(course) {
//                    storage.schedule.courses.append(course)
//                }
//                storage.saveSchedule()
//            }
//
//            controller.dismiss(animated: true, completion: nil)
//        default:
//            controller.dismiss(animated: true, completion: nil)
//        }
    }
    
}
