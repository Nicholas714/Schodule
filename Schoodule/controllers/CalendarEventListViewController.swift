//
//  CalendarEventListViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 9/26/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventListViewController: BubbleTableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var storage: Storage!
    let store = EKEventStore.store
    
    var selectedPaths = [IndexPath]() {
        didSet {
            saveButton.isEnabled = !selectedPaths.isEmpty
            saveButton.title = selectedPaths.isEmpty ? "Save" : "Save \(selectedPaths.count)"
        }
    }
    
    var selectedEntries = [BubbleEntry]()
    
    var isFiltering: Bool {
        if let searchController = navigationItem.searchController {
            return searchController.isActive && searchController.searchBar.text?.isEmpty ?? false
        }
        return false
    }
    
    var allEntries = [BubbleEntry]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a course"
        searchController.searchBar.tintColor = .white
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        self.navigationItem.searchController = searchController
        
        self.cellTapped = { (indexPath) in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? CalendarEventCell, let entry = cell.entry else {
                return
            }
                
            if self.selectedPaths.contains(indexPath) {
                if let index = self.selectedPaths.firstIndex(of: indexPath) {
                    self.selectedPaths.remove(at: index)
                }
                
                if let index = self.selectedEntries.firstIndex(of: entry) {
                    self.selectedEntries.remove(at: index)
                }
                
                cell.color = Color.unselected
            } else {
                self.selectedPaths.append(indexPath)
                self.selectedEntries.append(entry)
                
                cell.color = Color.randomBackground
            }
        }
        
        requestAccess {
            self.entries = self.store.allCoursesInCalendar()
                .filter { !self.storage.schedule.courses.contains($0) }
                .map { BubbleEntry(course: $0) }
            self.allEntries = self.entries
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true 
    }
    
    func requestAccess(done: @escaping () -> ()) {
        store.requestAccess(to: EKEntityType.event, completion: { (result, error) in
            if result && error == nil {
                done()
            }
        })
    }
    
    @IBAction func saveCourses(_ sender: UIBarButtonItem) {
        for entry in selectedEntries {
            let course = entry.course
            
            if !storage.schedule.courses.contains(course) {
                storage.schedule.courses.append(course)
            }
        }
        
        storage.saveSchedule()
        
        navigationController?.popViewController(animated: true)
    }
}

extension CalendarEventListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            return
        }
        
        var newEntries = [BubbleEntry]()
        
        for entry in allEntries {
            if entry.name.lowercased().contains(text.lowercased()) {
                newEntries.append(entry)
            }
        }
        
        entries = newEntries
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        entries = allEntries
    }
    
}
