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
    
    init(schoodule: Schoodule) {
        self.schoodule = schoodule
    }
    
    lazy var url: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    func saveSchedule() {
        
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(schoodule.periods)

            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError("Error loading periods.")
        }
    }
    
    func loadScheudle() {

        if !FileManager.default.fileExists(atPath: url.path) {
            return
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                for period in try decoder.decode([Period].self, from: data) {
                    schoodule.periods.append(period)
                }
            } catch {
                fatalError("Error decoding periods.")
            }
        }
        
    }
}
