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
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClassCreateSegue" {
            if let destination = segue.destination as? ClassCreateController {
                destination.scheduleList = storage.scheduleList
            }
        }
    }
    
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        storage.scheduleList = ScheduleList()
        tableView.reloadData()
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return storage.scheduleList.todayCourses.isEmpty ? "No Classes Today" : ""
        case 1:
            return storage.scheduleList.schedules.isEmpty ? "No Schedules" : storage.scheduleList.schedules[section - 1].title
        case _:
            return storage.scheduleList.schedules[section - 1].title
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell")!
        
        if indexPath.section == 0 {
            cell.textLabel?.text = storage.scheduleList.todayCourses[indexPath.row].name
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
            return storage.scheduleList.todayCourses.count
        case _:
            return storage.scheduleList.schedules.isEmpty ? 0 : storage.scheduleList.schedules[section - 1].classList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scheduleIndex = indexPath.section - 1
        let courseIndex = indexPath.row
       
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ClassCreate") as! ClassCreateController

        if scheduleIndex == -1 {
            let entry = storage.scheduleList.todayCourseEntries[courseIndex]
            nextViewController.initialCourse = entry.0
            nextViewController.initialSchedule = entry.1 
        } else {
            nextViewController.initialSchedule = storage.scheduleList.schedules[scheduleIndex]
            nextViewController.initialCourse = nextViewController.initialSchedule!.classList[courseIndex]
        }
        
        nextViewController.scheduleList = storage.scheduleList
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
}
