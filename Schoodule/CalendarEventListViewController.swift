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
            let year: TimeInterval = 604800
            let predicate = self.eventStore.predicateForEvents(withStart: Date().addingTimeInterval(-year), end: Date().addingTimeInterval(year), calendars: nil)
            
            let es = self.eventStore.events(matching: predicate)
            let found = Set(es.map { $0.title }).map({ (value) -> EKEvent in
                return es.first(where: { (event) -> Bool in
                    return event.title == value
                }) ?? EKEvent()
            })
            
            self.events = found
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
        let event = events[indexPath.row]
                
        let course = Course(name: event.title!)
        if !storage.schedule.courses.contains(course) {
                storage.schedule.courses.append(course)
        }
        storage.saveSchedule()
    }
    
}
