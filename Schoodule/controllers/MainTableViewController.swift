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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.tabBarController?.tabBar.isHidden = true
        navigationController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.isTranslucent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTodaySchedule), name: UIApplication.didBecomeActiveNotification, object: nil)

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
                self.editingEvent = Event(event: event, color: cell.color)
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
        
        reloadTodaySchedule()
    }
    
    @objc func reloadTodaySchedule() {
        navigationController?.setToolbarHidden(true, animated: false)
        var found = [EventBubbleEntry]()
        let todayCourses = storage.schedule.todayCourses
        for todayCourse in todayCourses {
            for var event in storage.schedule.todayEvents {
                if event.name == todayCourse.name {
                    event.color = todayCourse.color 
                    found.append(EventBubbleEntry(course: todayCourse, event: event))
                }
            }
        }
        
        self.entries = found
        tableView.reloadData()
        
        if storage.schedule.courses.isEmpty {
            createInfoLabel(withText: "Create a class or add one from Calendar")
        } else if todayCourses.isEmpty {
            createInfoLabel(withText: "No classes today")
        }
        
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
        
        editEventViewController.eventStore = store
        editEventViewController.event = event
        editEventViewController.editViewDelegate = self

        self.present(editEventViewController, animated: true, completion: nil)
    }
    
    func editEvent(event editingEvent: EKEvent?) {
        let editEventViewController = EKEventViewController()
        let store = EKEventStore.store
        let event = editingEvent ?? EKEvent(eventStore: store)
        
        editEventViewController.event = event
        editEventViewController.allowsCalendarPreview = true
        editEventViewController.allowsEditing = true
        editEventViewController.delegate = self
        
        self.navigationController?.pushViewController(editEventViewController, animated: true)
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

extension MainTableViewController: EKEventViewDelegate {
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        
        guard let event = controller.event else {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch action {
        case .deleted:
            if let deleted = editingEvent {
                self.storage.schedule.courses.removeAll(where: { $0.name == deleted.name })
                EventStore.reloadYear()
                storage.saveSchedule()
            }
        case .done:
            if let old = editingEvent {
                self.storage.schedule.courses.removeAll(where: { $0.name == old.name })
                storage.saveSchedule()
            }
            
            let course = Course(event: event, color: Color.randomBackground)
            
            self.storage.schedule.courses.append(course)
            self.storage.saveSchedule()

            EventStore.reloadYear()
            
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
