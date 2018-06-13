//
//  SchooduleTests.swift
//  SchooduleTests
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import XCTest

class SchooduleTests: XCTestCase {
    
    var storage: Storage! = nil
    
    override func setUp() {
        super.setUp()
        
        let sco = Class(name: "Scociology", themeIndex: 0, timeframe: Timeframe(start: Time(7, 05), end: Time(7, 45)), location: nil)
        let eco = Class(name: "Economics", themeIndex: 1, timeframe: Timeframe(start: Time(7, 50), end: Time(8, 35)), location: nil)
        let stats = Class(name: "Statistics", themeIndex: 2, timeframe: Timeframe(start: Time(8, 40), end: Time(9, 20)), location: nil)
        let lunch = Class(name: "Lunch", themeIndex: 3, timeframe: Timeframe(start: Time(9, 25), end: Time(10, 05)), location: nil)
        let calc = Class(name: "Calculus", themeIndex: 4, timeframe: Timeframe(start: Time(10, 10), end: Time(10, 50)), location: nil)
        let cs = Class(name: "Computer Science", themeIndex: 5, timeframe: Timeframe(start: Time(10, 55), end: Time(11, 35)), location: nil)
        let lit = Class(name: "Literature", themeIndex: 6, timeframe: Timeframe(start: Time(11, 40), end: Time(12, 20)), location: nil)
        let gym = Class(name: "Gym", themeIndex: 7, timeframe: Timeframe(start: Time(12, 25), end: Time(13, 05)), location: nil)
        let phy = Class(name: "Physics", themeIndex: 8, timeframe: Timeframe(start: Time(13, 10), end: Time(13, 50)), location: nil)
        let after1 = Class(name: "Afterschool1", themeIndex: 9, timeframe: Timeframe(start: Time(13, 50), end: Time(15, 05)), location: nil)
        let after2 = Class(name: "Afterschool2", themeIndex: 0, timeframe: Timeframe(start: Time(15, 05), end: Time(16, 40)), location: nil)
        
        storage = Storage()
        
        var classList = ClassList()
        classList.periods = [sco, eco, stats, lunch, calc, cs, lit, gym, phy, after1, after2]
        storage.scheduleList.schedules.append(classList)
    }
    
    func testDurations() {
        for schedule in storage.scheduleList.schedules {
            for c in schedule.periods {
                let ClassDurations = Int(c.timeframe.end.date.timeIntervalSinceNow - c.timeframe.start.date.timeIntervalSinceNow) / 60
                XCTAssertTrue([40, 45, 75, 95].contains(ClassDurations))
            }
        }
    }
    
    func testDateframe() {
        for var schedule in storage.scheduleList.schedules {
            schedule.addConstrait(Dateframe(start: Date(), end: Date().addingTimeInterval(100000)))
            print(schedule.dateframe?.title ?? "None.")
        }
        
    }
    
    func testGettingDate() {
        var schedule = storage.scheduleList.schedules.first!
        let date0 = schedule.periods.first!.timeframe.start.date.addingTimeInterval(-60)
        let date1 = schedule.periods.first!.timeframe.start.date.addingTimeInterval(60)
        let date2 = schedule.periods.first!.timeframe.end.date.addingTimeInterval(60)
        let date3 = schedule.lastPeriod!.timeframe.start.date.addingTimeInterval(60)
        
        // no class if date is before schedule
        XCTAssertNil(schedule.classFrom(date: date0))
        // first class should be given for next class if date given is before schedule start
        XCTAssertEqual(schedule.nextClassFrom(date: date0), schedule.periods.first!)
        // check for first class
        XCTAssertEqual(schedule.classFrom(date: date1), schedule.periods.first!)
        // if in between 2 classes it should give nil
        XCTAssertNil(schedule.classFrom(date: date2))
        // next class from first class should give second class
        XCTAssertEqual(schedule.nextClassFrom(date: date1), schedule.periods.first!)
        // check for last class
        XCTAssertEqual(schedule.classFrom(date: date3), schedule.periods.first!)
        // no class if date is after schedule
        XCTAssertNil(schedule.nextClassFrom(date: date3))
    }
    
    func testTodayList() {
        var nothingTodaySchedule = ScheduleList()
        var classList = ClassList()
        classList.addConstrait(SpecificDay(days: [Day]()))
        nothingTodaySchedule.schedules = [classList]
        
        XCTAssertEqual(nothingTodaySchedule.todaySchedule.count, 0)
        
        //schedule.timeConstraints = [.everyday()]
       // XCTAssertEqual(schedul, 11)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        self.measure {
            print("11293810238192")
        }
    }
    
}
