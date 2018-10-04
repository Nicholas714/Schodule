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
        
        self.cellTapped = { indexPath in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? CalendarEventCell, let eventEntry = cell.entry as? EventBubbleEntry else {
                return
            }
            
            if let event = EKEventStore.store.eventsForDate(date: Date())[eventEntry.startDate] {
                self.editEvent(event: event)
            } else {
                let event = EKEvent(eventStore: EKEventStore.store)
                event.title = eventEntry.name
                event.startDate = eventEntry.startDate
                event.endDate = eventEntry.endDate
                event.location = eventEntry.location
                
                self.editEvent(event: event)
            }
            
        }
        
        var found = [EventBubbleEntry]()
        for todayCourse in storage.schedule.todayCourses {
            for event in todayCourse.todayEvents {
                found.append(EventBubbleEntry(course: todayCourse, event: event))
            }
        }
        
        self.entries = found
        
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
        editEvent(event: nil)
    }
    
    func editEvent(event editingEvent: EKEvent?) {
        let event = editingEvent ?? EKEvent(eventStore: EKEventStore.store)
        let store = EKEventStore.store

        let editEventViewController = EKEventEditViewController()
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
        guard let event = controller.event else {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch action {
        case .deleted:
            if let course = storage.schedule.courses.first(where: { (course) -> Bool in
                return course.name == event.title
            }) {
                if let index = storage.schedule.courses.firstIndex(of: course) {
                    storage.schedule.courses.remove(at: index)
                    storage.saveSchedule()
                }
            }
            
        case .saved:
            if let course = storage.schedule.courses.first(where: { (course) -> Bool in
                return course.name == event.title
            }) {
                if !storage.schedule.courses.contains(course) {
                    storage.schedule.courses.append(course)
                    storage.saveSchedule()
                }
            } else {
                let course = Course(event: event, color: Color.randomBackground)
                course.events = EKEventStore.store.eventsMatching(course: course, in: nil)
                storage.schedule.courses.append(course)
                storage.saveSchedule()
                for todayEvent in course.todayEvents {
                    entries.append(EventBubbleEntry(course: course, event: todayEvent))
                }
                entries.sort()
            }
            
        default: break
        }
        
        controller.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
}
