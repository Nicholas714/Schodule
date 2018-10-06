//
//  EKEvent+RRule.swift
//  Schoodule
//
//  Created by Nicholas Grana on 10/6/18.
//  Copyright © 2018 Schoodule. All rights reserved.
//

import EventKit

extension EKEvent {
    
    var dtStart: Date {
        return self.occurrenceDate
    }
    
    private func byweekday(rule: EKRecurrenceRule) -> [Int] {
        var days = [Int]()
        
        if let daysOTW = rule.daysOfTheWeek {
            if daysOTW.isEmpty {
                return [Calendar.current.component(.weekday, from: dtStart)]
            } else {
                for d in daysOTW {
                    print(d.dayOfTheWeek.rawValue)
                    days.append(d.dayOfTheWeek.rawValue)
                }
                return days
            }
        }
        return [Calendar.current.component(.weekday, from: dtStart)]
    }
    
    var rrules: [RRule] {
        var rs = [RRule]()
        
        if let rules = recurrenceRules {
            for rule in rules {
                let rr = RRule(frequency: rule.freq,
                               dtstart: dtStart,
                               until: rule.until,
                               count: rule.count,
                               interval: rule.interval,
                               wkst: rule.wkst,
                               bysetpos: rule.bysetpos,
                               bymonth: rule.bymonth,
                               bymonthday: rule.bymonthday,
                               byyearday: rule.byyearday,
                               byweekno: rule.byweekno,
                               byweekday: byweekday(rule: rule),
                               byhour: [], byminute: [], bysecond: [], exclusionDates: [], inclusionDates: [])
                
                print(rr.occurences)

                rs.append(rr)
            }
        }
        return rs
    }
    
    
}

private extension EKRecurrenceRule {
    
    var freq: RruleFrequency {
        switch frequency {
        case .daily:
            return .daily
        case .monthly:
            return .monthly
        case .weekly:
            return .weekly
        default:
            return .daily
        }
    }
    
    var until: Date? {
        return recurrenceEnd?.endDate
    }
    
    var count: Int? {
        return nil
    }
    
    var wkst: Int {
        return firstDayOfTheWeek
    }
    
    var bysetpos: [Int] {
        if let pos = setPositions {
            return pos as! [Int]
        }
        return [Int]()
    }
    
    var bymonth: [Int] {
        if let month = monthsOfTheYear {
            return month as! [Int]
        }
        return [Int]()
    }
    
    var bymonthday: [Int] {
        if let month = daysOfTheMonth {
            return month as! [Int]
        }
        return [Int]()
    }
    
    var byyearday: [Int] {
        if let year = daysOfTheYear {
            return year as! [Int]
        }
        return [Int]()
    }
    
    var byweekno: [Int] {
        if let week = weeksOfTheYear {
            return week as! [Int]
        }
        return [Int]()
    }
    
}
