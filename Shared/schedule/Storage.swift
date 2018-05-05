//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
// 

import Foundation

class Storage {
    
    var manager: SchooduleManager {
        return SchooduleManager.shared
    }
    
    var encoded: Data {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(manager.schedules)
        } catch {
            fatalError("Error loading schedules.")
        }
    }

    func saveSchedule() {
        manager.defaults.setValue(encoded, forKey: "schedules")
    }
    
    func loadScheudle() {
        manager.schedules.removeAll()
        
        if let data = manager.defaults.value(forKey: "schedules") as? Data {
            let decoder = JSONDecoder()

            do {
                manager.schedules = try decoder.decode([Schedule].self, from: data)
            } catch {
                fatalError("Error decoding schedules.")
            }
        }
    }
    
}
