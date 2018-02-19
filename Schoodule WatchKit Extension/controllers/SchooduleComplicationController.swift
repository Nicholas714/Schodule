//
//  SchooduleComplicationController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import ClockKit
import WatchKit

class SchooduleComplicationController: NSObject, CLKComplicationDataSource {

    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    // shorthand for first period time of the day
    var scheduleStart: Date? {
        return schoodule.periods.first?.start.date.addingTimeInterval(-600) // 10 minutes to begining next class
    }
    
    // shorthand for last period time of the day
    var scheduleEnd: Date? {
        return schoodule.periods.last?.end.date
    }
    
    // given a date and compliation type, this will send back the current complication template
    func complicationTemplate(_ complication: CLKComplication, from date: Date? = nil) -> CLKComplicationTemplate? {
        
        var complicationType: ComplicationStore.PeriodComplication = .blank
        var dateProvider: CLKRelativeDateTextProvider? = nil
        var periodProvider: Period? = nil
        
        if let date = date {
            if let period = schoodule.classFrom(date: date) {
                
                dateProvider = CLKRelativeDateTextProvider(date: period.end.date, style: .natural, units: [.minute, .hour])
                periodProvider = period
                complicationType = .current
                
            } else if let nextClass = schoodule.nextClassFrom(date: date) {
                if schoodule.index(of: nextClass) == 0 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])
                    complicationType = .first
                    
                } else if schoodule.index(of: nextClass) == schoodule.unsortedPeriods.count - 1 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])
                    complicationType = .last
                    
                } else {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])
                    complicationType = .next
                    
                }
            }
        }

        return ComplicationStore(family: complication.family, period: periodProvider, dateProvider: dateProvider, type: complicationType).template
    }
    
    
    
    
    
    
    // MARK: Time Travel Support
    
    // supports backwards and forwards for seeing schedule
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    // block time travel for anything after the last schedule entry
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(scheduleEnd?.addingTimeInterval(30))
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
       handler(scheduleStart?.addingTimeInterval(-30))
    }
    
    

    
    
    
    // MARK: Timeline Creation
    
    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(ComplicationStore(family: complication.family, period: nil, dateProvider: nil, type: .placeholder).template)
    }
    
    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if let template = complicationTemplate(complication, from: Date()) {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }
    
    // gets all the entries before the date
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        guard let scheduleStart = self.scheduleStart, let scheduleEnd = self.scheduleEnd else {
            return
        }
        
        if date > scheduleStart.addingTimeInterval(-61) {
            // adds start entry to disable timer when it goes before
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart.addingTimeInterval(-61), complicationTemplate: complicationTemplate(complication)!))
        }
        if date > scheduleStart {
            // first class
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart, complicationTemplate: complicationTemplate(complication, from: scheduleStart)!))
        }
        
        
        for period in schoodule.periods where period.start.date < date && period.end.date < date {
            if let template = complicationTemplate(complication, from: period.start.date) {
                let timelineEntry: CLKComplicationTimelineEntry
                
                timelineEntry = CLKComplicationTimelineEntry(date: period.start.date, complicationTemplate: template)
                timelineEntires.append(timelineEntry)
                
                // if not the last class, put an entry to tell the time until the next class
                if scheduleEnd != period.end.date {
                    let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: period.end.date.addingTimeInterval(0.01), complicationTemplate: complicationTemplate(complication, from: period.end.date.addingTimeInterval(5))!)
                    timelineEntires.append(nextClassTimelineEntry)
                }
            } else {
                continue
            }
        }
        
        if date > scheduleEnd.addingTimeInterval(61) {
            // adds final entry to disable timer when it goes past
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleEnd.addingTimeInterval(61), complicationTemplate: complicationTemplate(complication)!))
        }
        
        handler(timelineEntires)
    }
    
    // gets all the entries after the date
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        guard let scheduleStart = self.scheduleStart, let scheduleEnd = self.scheduleEnd else {
            return
        }
        
        if date < scheduleStart.addingTimeInterval(-61) {
            // adds start entry to disable timer when it goes before
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart.addingTimeInterval(-61), complicationTemplate: complicationTemplate(complication)!))
        }
        if date < scheduleStart {
            // first class
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart, complicationTemplate: complicationTemplate(complication, from: scheduleStart)!))
        }
        
        for period in schoodule.periods where period.start.date > date && period.end.date > date {
            if let template = complicationTemplate(complication, from: period.start.date) {
                let timelineEntry: CLKComplicationTimelineEntry

                timelineEntry = CLKComplicationTimelineEntry(date: period.start.date, complicationTemplate: template)
                timelineEntires.append(timelineEntry)

                // if not the last class, put an entry to tell the time until the next class
                if scheduleEnd != period.end.date {
                    let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: period.end.date.addingTimeInterval(0.01), complicationTemplate: complicationTemplate(complication, from: period.end.date.addingTimeInterval(5))!)
                    timelineEntires.append(nextClassTimelineEntry)
                }
            } else {
                continue
            }
        }
        
        if date < scheduleEnd.addingTimeInterval(61) {
            // adds final entry to disable timer when it goes past
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleEnd.addingTimeInterval(61), complicationTemplate: complicationTemplate(complication)!))
        }
        
        
        handler(timelineEntires)
    }
    
    
}

