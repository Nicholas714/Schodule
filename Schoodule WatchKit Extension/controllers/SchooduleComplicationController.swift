//
//  SchooduleComplicationController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import ClockKit

class SchooduleComplicationController: NSObject, CLKComplicationDataSource {

    var schoodule: Schoodule {
        return SchooduleManager.shared.schoodule
    }
    
    let initialClassWarning: TimeInterval = -3600
    
    // shorthand for first period time of the day
    var scheduleStart: Date? {
        return schoodule.periods.first?.timeframe.start.date.addingTimeInterval(initialClassWarning) // go before a bit to fit first class warning
    }
    
    // shorthand for last period time of the day
    var scheduleEnd: Date? {
        return schoodule.periods.last?.timeframe.end.date
    }
    
    // given a date and compliation type, this will send back the current complication template
    func complicationTemplate(_ complication: CLKComplication, from date: Date? = nil) -> CLKComplicationTemplate? {
        
        var complicationType: ComplicationStore.PeriodComplication = .blank
        var dateProvider: CLKRelativeDateTextProvider? = nil
        var periodProvider: Period? = nil
        
        if let date = date {
            if let period = schoodule.classFrom(date: date) {
                
                dateProvider = CLKRelativeDateTextProvider(date: period.timeframe.end.date, style: .natural, units: [.minute, .hour])
                periodProvider = period
                complicationType = .current
                
            } else if let nextClass = schoodule.nextClassFrom(date: date) {
                if schoodule.index(of: nextClass) == 0 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.timeframe.start.date, style: .natural, units: [.minute, .hour])
                    complicationType = .first
                    
                } else if schoodule.index(of: nextClass) == schoodule.unsortedPeriods.count - 1 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.timeframe.start.date, style: .natural, units: [.minute, .hour])
                    complicationType = .last
                    
                } else {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextClass.timeframe.start.date, style: .natural, units: [.minute, .hour])
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
        handler(scheduleEnd?.addingTimeInterval(62))
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
       handler(scheduleStart?.addingTimeInterval(-62))
    }
    
    

    
    
    
    // MARK: Timeline Creation
    
    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(ComplicationStore(family: complication.family, period: nil, dateProvider: nil, type: .placeholder).template)
    }
    
    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        // send current template as long as it is within range of the schedule, otherwise send a blank one
        let now = Date()

        if let template = complicationTemplate(complication, from: now), let end = scheduleEnd, let start = scheduleStart, now > start && now < end {
            if let period = schoodule.classFrom(date: Date()) {
                handler(CLKComplicationTimelineEntry(date: period.timeframe.start.date, complicationTemplate: template))
            } else {
                handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            }
        } else {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: complicationTemplate(complication)!))
        }
        
    }
    
    // gets all the entries before the date
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        allTimelineEntries(complication: complication, for: date, handler: handler, with: >, sendNext: false)
    }
    
    // gets all the entries after the date
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        allTimelineEntries(complication: complication, for: date, handler: handler, with: <, sendNext: true)
    }
    
    func allTimelineEntries(complication: CLKComplication, for date: Date, handler: ([CLKComplicationTimelineEntry]?) -> Void, with comparision: ((Date, Date) -> Bool), sendNext: Bool) {
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        guard let scheduleStart = self.scheduleStart, let scheduleEnd = self.scheduleEnd else {
            return
        }
        
        if comparision(date, scheduleStart.addingTimeInterval(-61)) {
            // adds start entry to disable timer when it goes before
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart.addingTimeInterval(-61), complicationTemplate: complicationTemplate(complication)!))
        }
        if comparision(date, scheduleStart) {
            // first class
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart, complicationTemplate: complicationTemplate(complication, from: scheduleStart)!))
        }
        
        for period in schoodule.periods {
            let current = schoodule.classFrom(date: Date())
            
            if let template = complicationTemplate(complication, from: period.timeframe.start.date) {
                if (!comparision(date, period.timeframe.start.date) && !comparision(date, period.timeframe.end.date)) {

                    if sendNext && current == period {
                        if scheduleEnd != period.timeframe.end.date {
                            // do not add class, but add next class entry
                            let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: period.timeframe.end.date, complicationTemplate: complicationTemplate(complication, from: period.timeframe.end.date.addingTimeInterval(5))!)
                            timelineEntires.append(nextClassTimelineEntry)
                        }
                    }

                    continue
                }
                
                let timelineEntry: CLKComplicationTimelineEntry
                
                timelineEntry = CLKComplicationTimelineEntry(date: period.timeframe.start.date, complicationTemplate: template)
                timelineEntires.append(timelineEntry)
                
                // if not the last class, put an entry to tell the time until the next class
                if scheduleEnd != period.timeframe.end.date {
                    let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: period.timeframe.end.date, complicationTemplate: complicationTemplate(complication, from: period.timeframe.end.date.addingTimeInterval(5))!)
                    timelineEntires.append(nextClassTimelineEntry)
                }
            } else {
                continue
            }
        }
        
        if comparision(date, scheduleEnd.addingTimeInterval(61)) {
            // adds final entry to disable timer when it goes past
            timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleEnd.addingTimeInterval(61), complicationTemplate: complicationTemplate(complication)!))
        }
        
        handler(timelineEntires)
    }
    
}

