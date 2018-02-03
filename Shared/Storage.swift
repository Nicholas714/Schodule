//
//  Storage.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/31/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import Foundation
import UIKit

class Storage {
    
    var schoodule: Schoodule
    
    var defaults: UserDefaults {
        get {
            return UserDefaults()
        }
    }
    
    init(schoodule: Schoodule) {
        self.schoodule = schoodule
    }
    
    func saveSchedule() {
        
        if let encoded = encodePeriods() {
            defaults.setValue(encoded, forKey: "periods")
        }

    }
    
    func loadScheudle() {
        schoodule.unsortedPeriods.removeAll()
        
        if let data = defaults.value(forKey: "periods") as? Data {
            let decoder = JSONDecoder()
            
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    schoodule.unsortedPeriods.append(period)
                }
            } catch {
                fatalError("Error decoding periods.")
            }
        }
    }
    
    func encodePeriods() -> Data? {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(schoodule.periods)
        } catch {
            fatalError("Error loading periods.")
        }
    }
    
    func decodePeriods(from data: Data) {
        schoodule.unsortedPeriods.removeAll()
        
        let decoder = JSONDecoder()
        
        do {
            for period in try decoder.decode([Period].self, from: data) {
                schoodule.unsortedPeriods.append(period)
            }
        } catch {
            fatalError("Error decoding periods.")
        }
    }
}
