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
        
        switch manager.scheduleStatus {
        case .both:
            switch section {
            case 0:
                return "Today"
            case 1:
                return "Schedules"
            default:
                return nil
            }
        case .schedules:
            return "Schedules"
        default:
            return nil
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")!
    
        cell.textLabel?.text = "HELLO"
        
        if indexPath.section == 0 {
            // either today or schedules
            // cell.textLabel?.text = schoodule.classFrom(date: Date())?.className
        } else if indexPath.section == 1 {
            // schedules
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("\(manager.scheduleStatus.rawValue)")
        return manager.scheduleStatus.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch manager.scheduleStatus {
        case .both:
            if section == 1 { // today
                return manager.todaySchedule.count
            } else { // schedules
                return manager.schedules.count
            }
        case .schedules:
            return SchooduleManager.shared.schedules.count
        default:
            return 0
        }
    }
    
}
