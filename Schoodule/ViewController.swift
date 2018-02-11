//
//  ViewController.swift
//  FoldingCellTest
//
//  Created by Nicholas Grana on 2/4/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import WatchConnectivity

fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 105 // equal or greater foregroundView height
        static let open: CGFloat = 320 // equal or greater containerView height
    }
}

class MainTableViewController: UITableViewController {
    
    var session: WCSession?
    
    static var schoodule = Schoodule()
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    var transfer: [String: Data] {
        return ["periods": MainTableViewController.schoodule.storage.encoded]
    }
    
    func startSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func saveSchedule() {
        defaults.setValue(MainTableViewController.schoodule.storage.encoded, forKey: "periods")
    }
    
    func loadScheudle() {
        MainTableViewController.schoodule.unsortedPeriods.removeAll()
        
        if let data = defaults.value(forKey: "periods") as? Data {
            let decoder = JSONDecoder()
            
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    MainTableViewController.schoodule.unsortedPeriods.append(period)
                }
            } catch {
                fatalError("Error decoding periods.")
            }
        }
    }
    
    let kCloseCellHeight: CGFloat = 105
    let kOpenCellHeight: CGFloat = 320
    var kRowsCount: Int {
        return MainTableViewController.schoodule.periods.count
    }
    var cellHeights: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScheudle()
        startSession()
        
        setup()
    }
    
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.black // UIColor(patternImage: #imageLiteral(resourceName: "background.png"))
    }
}

extension MainTableViewController {
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return MainTableViewController.schoodule.periods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as PeriodCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}

extension MainTableViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String, message == "refreshRequest" {
            replyHandler(transfer)
        } else if let message = message["message"] as? String, message == "clear" {
            MainTableViewController.schoodule.clear()
            saveSchedule()
            
            replyHandler(transfer)
            
            DispatchQueue.main.async {
                self.setup()
                self.tableView.reloadData()
            }
        } else if let data = message["periods"] as? Data {
            MainTableViewController.schoodule.storage.decodePeriods(from: data)
            saveSchedule()
            
            replyHandler(transfer)
            
            DispatchQueue.main.async {
                self.setup()
                self.tableView.reloadData()
            }
        }
    }
    
    
    
}
