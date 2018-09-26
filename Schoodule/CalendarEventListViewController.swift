//
//  CalendarEventListViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 9/26/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventListViewController: UITableViewController {
    
    var storage: Storage!
    
    var eventStore = EKEventStore()
    var events = [EKEvent]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestAccess {
            let year = 3.15576e7
            let predicate = self.eventStore.predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
            
            let foundEvents = Set(self.eventStore.events(matching: predicate).filter { !self.storage.schedule.courses.contains(Course(eventIdentifier: $0.eventIdentifier)) }.map { $0.eventIdentifier! })
            self.events = foundEvents.map { self.eventStore.event(withIdentifier: $0)! }
            print("\(foundEvents.count) to \(self.events.count)")
        }
    }
    
    func requestAccess(done: @escaping () -> ()) {
        EKEventStore().requestAccess(to: EKEntityType.event, completion: { (result, error) in
            if result && error == nil {
                done()
            }
        })
    }
    
}

extension CalendarEventListViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
        cell.textLabel?.text = events[indexPath.row].title
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCourse = Course(eventIdentifier: events[indexPath.row].eventIdentifier!)
        if !storage.schedule.courses.contains(newCourse) {
            storage.schedule.courses.append(newCourse)
        }
        storage.saveSchedule()
    }
    
}
