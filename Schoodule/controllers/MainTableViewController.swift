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

class MainTableViewController: BubbleTableViewController, Actable {
    
    var storage = Storage(defaults: UserDefaults())
    var session: WCSession? = nil
    
    var editingEvent: Event? {
        didSet {
            if let _ = editingEvent {
                navigationController?.navigationBar.barTintColor = UIColor.black
                navigationController?.navigationBar.isTranslucent = false
            } else {
                navigationController?.navigationBar.barTintColor = nil
                navigationController?.navigationBar.isTranslucent = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.tabBarController?.tabBar.isHidden = true
        navigationController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.isTranslucent = true
        
        if WCSession.isSupported() && session == nil {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        self.cellTapped = { indexPath in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? CalendarEventCell, let eventEntry = cell.entry as? EventBubbleEntry else {
                return
            }
            
            if let events = EKEventStore.store.eventsForDate(date: Date())[eventEntry.startDate] {
                for event in events {
                    if event.title == eventEntry.name {
                        self.editingEvent = Event(event: event, color: cell.color)
                        self.editEvent(event: event)
                    }
                    break
                }
            } else {
                let event = EKEvent(eventStore: EKEventStore.store)
                event.title = eventEntry.name
                event.startDate = eventEntry.startDate
                event.endDate = eventEntry.endDate
                event.location = eventEntry.location
                
                self.editEvent(event: event)
            }
            
        }
        
        createEntries()
    }
    
    func didBecomeActive() {
        createEntries()
    }
    
    func createEntries() {
        navigationController?.setToolbarHidden(true, animated: false)

        self.entries = storage.schedule.todayEvents.map { EventBubbleEntry(event: $0) }
        
        if storage.schedule.courses.isEmpty {
            createInfoLabel(withText: "Create a class or add one from Calendar")
        } else if storage.schedule.todayCourses.isEmpty {
            createInfoLabel(withText: "No classes today")
        }
        
        tableView.reloadData()
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
        createEvent()
    }
    
    func createEvent() {
        let editEventViewController = EKEventEditViewController()
        let store = EKEventStore.store
        let event = EKEvent(eventStore: store)
        
        if event.calendar == nil {
            event.calendar = calendarForEvent(event: event)
        }
        
        editEventViewController.eventStore = store
        editEventViewController.event = event
        editEventViewController.editViewDelegate = self

        self.present(editEventViewController, animated: true, completion: nil)
    }
    
    func editEvent(event editingEvent: EKEvent?) {
        let editEventViewController = EKEventViewController()
        let store = EKEventStore.store
        let event = editingEvent ?? EKEvent(eventStore: store)
    
        if editingEvent == nil {
            event.calendar = calendarForEvent(event: event)
        }
        
        editEventViewController.event = event
        editEventViewController.allowsCalendarPreview = true
        editEventViewController.allowsEditing = true
        editEventViewController.delegate = self
        
        self.navigationController?.pushViewController(editEventViewController, animated: true)
    }
    
    func calendarForEvent(event: EKEvent) -> EKCalendar {
        let store = EKEventStore.store
        let newCalendar: EKCalendar
        
        if let defaultCalendar = store.defaultCalendarForNewEvents {
            newCalendar = defaultCalendar
            
        } else {
            let schooduleCalendar = store.calendars(for: .event).filter { $0.title == "Schoodule" }.first
            if let cal = schooduleCalendar {
                newCalendar = cal
            } else {
                newCalendar = EKCalendar(for: .event, eventStore: store)
                newCalendar.title = "Schoodule"
                let source = store.sources.filter { $0.sourceType.rawValue == EKSourceType.local.rawValue }.first
                if let source = source {
                    newCalendar.source = source
                }
                
                try? store.saveCalendar(newCalendar, commit: true)
            }
        }
        
        return newCalendar
    }
    
}

extension MainTableViewController: EKEventViewDelegate {
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        print("TESING!!! WHY NOT CALLED?")
        
        switch action {
        case .deleted:
            if let deleted = editingEvent {
                self.storage.schedule.courses.removeAll(where: { $0.name == deleted.name })
                storage.saveSchedule()
                EventStore.reloadYear()
            }
        default: break
        }

        navigationController?.popViewController(animated: true)
        navigationController?.tabBarController?.tabBar.isHidden = true
        tableView.reloadData()
    }
    
}

// MARK:- EKEventViewDelegate

extension MainTableViewController: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        print("hello...?")
        
        switch action {
        case .saved:
            guard let event = controller.event, let _ = event.title else {
                controller.dismiss(animated: true)
                return
            }
            
            let course = Course(event: event, color: Color.randomBackground)
            self.storage.schedule.courses.append(course)
            
            EventStore.reloadYear()
            self.storage.saveSchedule()

            break
        default:
            break
        }

        tableView.reloadData()
        controller.dismiss(animated: true)
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
