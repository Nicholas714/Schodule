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
    
    var encoded: Data {
        let encoder = JSONEncoder()
        
        do {
            return try encoder.encode(schoodule.periods)
        } catch {
            fatalError("Error loading periods.")
        }
    }
    
    init(schoodule: Schoodule) {
        self.schoodule = schoodule
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
