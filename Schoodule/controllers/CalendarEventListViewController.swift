//
//  CalendarEventListViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 9/26/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventListViewController: BubbleTableViewController {
    
    var storage: Storage!
    let store = EKEventStore()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestAccess {
            self.courses = self.store.allCoursesInCalendar()
        }
    }
    
    func requestAccess(done: @escaping () -> ()) {
        store.requestAccess(to: EKEntityType.event, completion: { (result, error) in
            if result && error == nil {
                done()
            }
        })
    }
    
}

extension CalendarEventListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let courses = courses {
            let course = courses[indexPath.row]
            
            if !storage.schedule.courses.contains(course) {
                storage.schedule.courses.append(course)
            }
            
            storage.saveSchedule()
        }
    }
    
}
