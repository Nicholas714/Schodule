//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
// 

import Foundation

class Storage {
    
    var schoodule: Schoodule
    
    var encoded: Data {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(schoodule.unsortedPeriods)
        } catch {
            fatalError("Error loading periods.")
        }
    }
    
    init(schoodule: Schoodule) {
        self.schoodule = schoodule
    }
    
    @discardableResult func decodePeriods(from data: Data) -> Bool {
        schoodule.unsortedPeriods.removeAll()
        
        let decoder = JSONDecoder()
        
        do {
            for period in try decoder.decode([Period].self, from: data) {
                schoodule.unsortedPeriods.insert(period)
            }
            
            let past = schoodule.periods
            
            schoodule.periods = schoodule.unsortedPeriods.sorted()
            SchooduleManager.shared.saveSchedule()
            if past == schoodule.periods {
                return true
            }
            
        } catch {
            fatalError("Error decoding periods.")
        }
        
        return false
    }
}
