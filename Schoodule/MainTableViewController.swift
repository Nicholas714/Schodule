//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    var storage = Storage(defaults: UserDefaults())
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClassCreateSegue" {
            if let destination = segue.destination as? ClassCreateController {
                // TODO: if selected a course and schedule, populate the destinationVC
                destination.course = nil
                destination.schedule = nil
                destination.scheduleList = storage.scheduleList
            }
        }
    }
    
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return storage.scheduleList.todaySchedule.isEmpty ? "No Classes Today" : ""
        case 1:
            return storage.scheduleList.schedules.isEmpty ? "No Schedules" : storage.scheduleList.schedules[section - 1].title
        case _:
            return storage.scheduleList.schedules[section - 1].title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")!
        
        // storage.storage.scheduleList.schedulePeriod(scheduleIndex, periodIndex)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = storage.scheduleList.todaySchedule[indexPath.row].name
        } else {
            cell.textLabel?.text = storage.scheduleList.schedules[indexPath.section - 1].classList[indexPath.row].name
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return storage.scheduleList.schedules.isEmpty ? 2 : storage.scheduleList.schedules.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return storage.scheduleList.todaySchedule.count
        case _:
            return storage.scheduleList.schedules.isEmpty ? 0 : storage.scheduleList.schedules[section - 1].classList.count
        }
    }
    
}
