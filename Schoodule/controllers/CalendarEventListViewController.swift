//
//  CalendarEventListViewController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 9/26/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventListViewController: BubbleTableViewController, Actable {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var storage: Storage!
    let store = EKEventStore.store
    
    var isFiltering: Bool {
        if let searchController = navigationItem.searchController {
            return searchController.isActive && searchController.searchBar.text?.isEmpty ?? false
        }
        return false
    }
    
    var allEntries = [BubbleEntry]()
    
    var initialColoredEntries = [String: Color]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if EventStore.shared.namesToCounts.isEmpty {
            createInfoLabel(withText: "No Calendar events")
        }
                
        setupSearchController()
        
        for course in self.storage.schedule.courses {
            initialColoredEntries[course.name] = course.color
        }
        
        requestAccess {
            DispatchQueue.main.async {
                self.setupEntries()
            }
        }
        
        
        self.cellTapped = { (indexPath) in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? CalendarEventCell, let entry = cell.entry else {
                return
            }
            
            let course = entry.course

            if self.storage.schedule.courses.contains(course) {
                cell.color = Color.unselected
                entry.course.color = Color.unselected
                self.storage.schedule.courses.removeAll(where: { $0 == course })
                self.storage.saveSchedule()
            } else {
                cell.color = self.initialColoredEntries[entry.name] ?? Color.randomBackground
                self.initialColoredEntries[entry.name] = cell.color
                entry.course.color = cell.color
                self.storage.schedule.courses.append(entry.course)
                self.storage.saveSchedule()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        initialColoredEntries.removeAll()
    }
    
    func didBecomeActive() {
        setupEntries()
    }
    
    func setupEntries() {
        self.entries = EventStore.shared.namesToCourse.values.map {
            let entry = BubbleEntry(course: $0)
            if let entryCourse = self.storage.schedule.courses.first(where: { $0.name == entry.name }) {
                entry.course = entryCourse
            }
            return entry
            }.sorted()
        self.allEntries = self.entries
    }
    
    func setupSearchController() {
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
    }
    
    func requestAccess(done: @escaping () -> ()) {
        store.requestAccess(to: EKEntityType.event, completion: { (result, error) in
            if result && error == nil {
                done()
            }
        })
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
        
        entries = newEntries.sorted()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        entries = allEntries.sorted()
    }
    
}
