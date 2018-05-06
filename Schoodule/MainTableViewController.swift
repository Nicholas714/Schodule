//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    var manager: SchooduleManager {
        return SchooduleManager.shared
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return manager.todaySchedule.isEmpty ? "No Classes Today" : "Today"
        case 1:
            return manager.schedules.isEmpty ? "No Schedules" : manager.schedules[section - 1].title
        case _:
            return manager.schedules[section - 1].title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")!
        
        if indexPath.section == 0 {
            cell.textLabel?.text = manager.todaySchedule[indexPath.row].className
        } else {
            cell.textLabel?.text = manager.schedules[indexPath.section - 1].periods[indexPath.row].className
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return manager.schedules.isEmpty ? 2 : manager.schedules.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return manager.todaySchedule.count
        case _:
            return manager.schedules.isEmpty ? 0 : manager.schedules[section - 1].periods.count
        }
    }
    
}
