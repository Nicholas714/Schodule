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
        
        let sco = Course(name: "Scociology", themeIndex: 0, timeframe: Timeframe(start: Time(7, 05), end: Time(7, 45)), location: nil)
        let eco = Course(name: "Economics", themeIndex: 1, timeframe: Timeframe(start: Time(7, 50), end: Time(8, 35)), location: nil)
        let stats = Course(name: "Statistics", themeIndex: 2, timeframe: Timeframe(start: Time(8, 40), end: Time(9, 20)), location: nil)
        let lunch = Course(name: "Lunch", themeIndex: 3, timeframe: Timeframe(start: Time(9, 25), end: Time(10, 05)), location: nil)
        let calc = Course(name: "Calculus", themeIndex: 4, timeframe: Timeframe(start: Time(10, 10), end: Time(10, 50)), location: nil)
        let cs = Course(name: "Computer Science", themeIndex: 5, timeframe: Timeframe(start: Time(10, 55), end: Time(11, 35)), location: nil)
        let lit = Course(name: "Literature", themeIndex: 6, timeframe: Timeframe(start: Time(11, 40), end: Time(12, 20)), location: nil)
        let gym = Course(name: "Gym", themeIndex: 7, timeframe: Timeframe(start: Time(12, 25), end: Time(13, 05)), location: nil)
        let phy = Course(name: "Physics", themeIndex: 8, timeframe: Timeframe(start: Time(13, 10), end: Time(13, 50)), location: nil)
        let after1 = Course(name: "Afterschool1", themeIndex: 9, timeframe: Timeframe(start: Time(13, 50), end: Time(15, 05)), location: nil)
        let after2 = Course(name: "Afterschool2", themeIndex: 0, timeframe: Timeframe(start: Time(15, 05), end: Time(16, 40)), location: nil)
        
        storage = Storage(defaults: UserDefaults())
        
        var schedule = Schedule()
        schedule.classList = [sco, eco, stats, lunch, calc, cs, lit, gym, phy, after1, after2]
        storage.scheduleList.schedules.append(schedule)
    }

    func testDurations() {
        for schedule in storage.scheduleList.schedules {
            for c in schedule.classList {
                let classDuration = Int(c.timeframe.end.date.timeIntervalSinceNow - c.timeframe.start.date.timeIntervalSinceNow) / 60
                print(classDuration)
                XCTAssertTrue([40, 45, 75, 95].contains(classDuration))
            }
        }
    }


    func testGettingDate() {
        let scheduleList = storage.scheduleList
        var schedule = scheduleList.schedules.first!

        let beforeStart = schedule.classList.first!.timeframe.start.date.addingTimeInterval(-60)
        let inFirstClass = schedule.classList.first!.timeframe.start.date.addingTimeInterval(60)
        let inBetweenClasses = schedule.classList.first!.timeframe.end.date.addingTimeInterval(60)
        let inLastClass = schedule.classList.last!.timeframe.start.date.addingTimeInterval(60)

        // no class if date is before schedule
        XCTAssertNil(scheduleList.classFrom(date: beforeStart))
        
        // first class should be given for next class if date given is before schedule start
        XCTAssertEqual(scheduleList.nextClassFrom(date: beforeStart), schedule.classList.first!)
        
        // check for first class
        XCTAssertEqual(scheduleList.classFrom(date: inFirstClass), schedule.classList.first!)
        
        // if in between 2 classes it should give nil
        XCTAssertNil(scheduleList.classFrom(date: inBetweenClasses))
        
        // next class from first class should give second class
        XCTAssertEqual(scheduleList.nextClassFrom(date: inFirstClass), schedule.classList[1])
        
        // check for last class
        XCTAssertEqual(scheduleList.classFrom(date: inLastClass), schedule.classList.last!)
        
        // no class if date is after schedule
        XCTAssertNil(scheduleList.nextClassFrom(date: inLastClass))
    }
    

    func testTodayList() {
        var nothingTodaySchedule = ScheduleList()
        var schedule = Schedule()
        schedule.setConstraints([SpecificDay(days: [Day]())])
        nothingTodaySchedule.schedules = [schedule]
        XCTAssertEqual(nothingTodaySchedule.todaySchedule.count, 0)
        
        var fullSchedule = ScheduleList()
        schedule.setConstraints([SpecificDay(days: Day.everyday)])
        schedule.classList = storage.scheduleList.schedules.first!.classList
        fullSchedule.schedules = [schedule]
        XCTAssertEqual(fullSchedule.todaySchedule.count, 11)
    }
    
    func testToday() {
        let date = Date()
        let time = Time(from: date)
        
        print("It is \(Day(rawValue: Calendar.current.component(.weekday, from: time.date))!) at \(time.hour):\(time.minute) \(time.isAM ? "AM" : "PM") for full date \(time.date)")
    }
    
}
