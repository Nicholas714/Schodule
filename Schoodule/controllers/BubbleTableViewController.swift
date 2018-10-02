//
//  BubbleTableView.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/2/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class BubbleTableViewController: UITableViewController {
    
    var events: [EKEvent]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var courses: [Course]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell")
        
        if cell == nil {
            tableView.register(UINib(nibName: "CalendarEventCell", bundle: nil), forCellReuseIdentifier: "CalendarEventCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell")
        }
        
        let eventCell = cell as! CalendarEventCell
        
        if let courses = courses {
            eventCell.course = courses[indexPath.row]
        } else if let events = events {
            eventCell.event = events[indexPath.row]
        }
        
        return eventCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses?.count ?? events?.count ?? 0 
    }

}
