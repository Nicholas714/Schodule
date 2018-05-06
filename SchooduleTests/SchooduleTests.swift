//
//  SchooduleTests.swift
//  SchooduleTests
//
//  Created by Nicholas Grana on 5/5/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import XCTest

class SchooduleTests: XCTestCase {
    
    var schedule: Schedule!
    
    var manager: SchooduleManager {
        return SchooduleManager.shared
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let sco = Period(className: "Scociology", themeIndex: 0, timeframe: Timeframe(start: Time(7, 05), end: Time(7, 45)), location: nil)
        let eco = Period(className: "Economics", themeIndex: 1, timeframe: Timeframe(start: Time(7, 50), end: Time(8, 35)), location: nil)
        let stats = Period(className: "Statistics", themeIndex: 2, timeframe: Timeframe(start: Time(8, 40), end: Time(9, 20)), location: nil)
        let lunch = Period(className: "Lunch", themeIndex: 3, timeframe: Timeframe(start: Time(9, 25), end: Time(10, 05)), location: nil)
        let calc = Period(className: "Calculus", themeIndex: 4, timeframe: Timeframe(start: Time(10, 10), end: Time(10, 50)), location: nil)
        let cs = Period(className: "Computer Science", themeIndex: 5, timeframe: Timeframe(start: Time(10, 55), end: Time(11, 35)), location: nil)
        let lit = Period(className: "Literature", themeIndex: 6, timeframe: Timeframe(start: Time(11, 40), end: Time(12, 20)), location: nil)
        let gym = Period(className: "Gym", themeIndex: 7, timeframe: Timeframe(start: Time(12, 25), end: Time(13, 05)), location: nil)
        let phy = Period(className: "Physics", themeIndex: 8, timeframe: Timeframe(start: Time(13, 10), end: Time(13, 50)), location: nil)
        let after1 = Period(className: "Afterschool1", themeIndex: 9, timeframe: Timeframe(start: Time(13, 50), end: Time(15, 05)), location: nil)
        let after2 = Period(className: "Afterschool2", themeIndex: 0, timeframe: Timeframe(start: Time(15, 05), end: Time(16, 40)), location: nil)
        
        schedule = Schedule()
        schedule.periods = [sco, eco, stats, lunch, calc, cs, lit, gym, phy, after1, after2]
        
        manager.schedules.append(schedule)
    }
    
    func testDurations() {
        for period in schedule.periods {
            let periodDurations = Int(period.timeframe.end.date.timeIntervalSinceNow - period.timeframe.start.date.timeIntervalSinceNow) / 60
            XCTAssertTrue([40, 45, 75, 95].contains(periodDurations))
        }
    }
    
    func testGettingDate() {
        let date0 = schedule.periods[0].timeframe.start.date.addingTimeInterval(-60)
        let date1 = schedule.periods[0].timeframe.start.date.addingTimeInterval(60)
        let date2 = schedule.periods[0].timeframe.end.date.addingTimeInterval(60)
        let date3 = schedule.lastPeriod!.timeframe.start.date.addingTimeInterval(60)
        
        // no class if date is before schedule
        XCTAssertNil(schedule.classFrom(date: date0))
        // first class should be given for next class if date given is before schedule start
        XCTAssertEqual(schedule.nextClassFrom(date: date0), schedule.periods[0])
        // check for first class
        XCTAssertEqual(schedule.classFrom(date: date1), schedule.periods[0])
        // if in between 2 classes it should give nil
        XCTAssertNil(schedule.classFrom(date: date2))
        // next class from first class should give second class
        XCTAssertEqual(schedule.nextClassFrom(date: date1), schedule.periods[1])
        // check for last class
        XCTAssertEqual(schedule.classFrom(date: date3), schedule.lastPeriod!)
        // no class if date is after schedule
        XCTAssertNil(schedule.nextClassFrom(date: date3))
    }
    
    func testTodayList() {
        let nothingTodaySchedule = Schedule()
        nothingTodaySchedule.timeConstraints = [SpecificDay(days: [Day]())]
        nothingTodaySchedule.periods = schedule.periods
        manager.schedules = [nothingTodaySchedule]
        XCTAssertEqual(manager.todaySchedule.count, 0)
        
        schedule.timeConstraints = [Everyday()]
        manager.schedules = [schedule]
        XCTAssertEqual(manager.todaySchedule.count, 11)
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
