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
    
    var cellHeight: CGFloat = 80
    var infoLabel: UILabel?
    
    var cellTapped: ((_ indexPath: IndexPath) -> ())? = nil
    
    var entries = [BubbleEntry]() {
        didSet {
            entries.sort()
            
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell(_:)))
        eventCell.addGestureRecognizer(tap)
        
        eventCell.entry = entries[indexPath.row]
        infoLabel?.isHidden = true
        
        return eventCell
    }
    
    @objc func tapCell(_ gesture: UITapGestureRecognizer) {
        if let cellTapped = cellTapped {
            if let cell = gesture.view as? CalendarEventCell, let indexPath = tableView.indexPath(for: cell) {
                cellTapped(indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func createInfoLabel(withText text: String) {
        let tableViewHeight = self.tableView.bounds.size.height
        var calc = (tableViewHeight / cellHeight) / 2
        calc = calc - 3;
        
        if infoLabel == nil {
            infoLabel = UILabel(frame: CGRect(x: 0, y: calc * cellHeight, width: self.tableView.bounds.size.width, height: cellHeight))
        }
 
        infoLabel?.isHidden = false
        infoLabel?.textColor = .white
        infoLabel?.numberOfLines = 10
        infoLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        infoLabel?.textAlignment = .center
        infoLabel?.text = text
        
        tableView.addSubview(infoLabel!)
    }
    
}
