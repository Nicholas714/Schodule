//
//  SchooduleManager+iOS.swift
//  Schoodule
//
//  Created by Nicholas Grana on 2/19/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation

extension SchooduleManager {
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    func saveSchedule() {
        defaults.setValue(schoodule.storage.encoded, forKey: "periods")
    }
    
    func loadScheudle() {
        schoodule.unsortedPeriods.removeAll()
        
        if let data = defaults.value(forKey: "periods") as? Data {
            let decoder = JSONDecoder()
            
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    schoodule.unsortedPeriods.insert(period)
                }
                schoodule.periods = schoodule.unsortedPeriods.sorted()
            } catch {
                fatalError("Error decoding periods.")
            }
        }
    }
    
}
