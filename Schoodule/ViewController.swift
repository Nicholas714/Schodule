//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    @IBOutlet var scheduleTableView: UITableView!
    
    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    @IBAction func click(_ sender: Any) {
        if let period = schoodule.classFrom(date: Date()) {
            schoodule.replace(old: period, with: Period(className: "\(period.className)!", themeIndex: 0, start: period.start, end: period.end))
        }
        
        SchooduleManager.shared.saveSchedule()
        SchooduleManager.shared.session?.transferCurrentComplicationUserInfo(schoodule.transfer)
    }
    @IBAction func renameCurrent(_ sender: UIBarButtonItem) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleTableView.separatorStyle = .none
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoodule.unsortedPeriods.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.frame = CGRect.zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusePeriod", for: indexPath)
        
        cell.selectionStyle = .none
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = cell.contentView.frame.height / 2
        cell.contentView.backgroundColor = schoodule.unsortedPeriods.sorted()[indexPath.row].color
        cell.textLabel?.text = schoodule.periods[indexPath.row].className
        cell.textLabel?.backgroundColor = UIColor.clear
        
        return cell
    }
    
}
