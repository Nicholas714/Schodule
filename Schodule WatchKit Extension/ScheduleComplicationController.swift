//
//  ScheduleComplicationController.swift
//  Schodule
//
//  Created by Nicholas Grana on 9/13/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import ClockKit

class ScheduleComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: Properties
    
    // start of the schedule (set to 7:05 am)
    var morningStart: Date {
        get {
            let calender = Calendar.current
            return calender.date(bySettingHour: 7, minute: 05, second: 0, of: Date())!
        }
    }
    
    
    // actual schedule which will be generated based on classPeriodTime and hallTime
    var schedule: Schedule {
        return Schedule(start: morningStart, classPeriodTime: 40, hallTime: 5, periods: "Intro to Criminology", "Electronics 1", "AP Statistics", "Lunch", "AP Calculus", "AP Comp Science", "AP Literature", "Physical Education", "AP Physics")
    }
    
    // MARK - Model functions
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        handler(morningStart.addingTimeInterval(86405))
    }
    
    func requestedUpdateDidBegin() {
        let server=CLKComplicationServer.sharedInstance()
        
        guard let active = server.activeComplications else {
            return
        }
        
        for complication in active {
            server.reloadTimeline(for: complication)
        }
    }
    
    // given a date and compliation type, this will send back the current template
    func complicationTemplate(_ complication: CLKComplication, from date: Date = Date(), blank: Bool = false) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()

            if blank {
                template.headerTextProvider = CLKSimpleTextProvider(text: "Time")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Class")
                return template
            }
            
            if let period = schedule.getClass(from: date) {
                template.headerTextProvider = CLKRelativeDateTextProvider(date: period.finishDate, style: .natural, units: [.minute])
                template.body1TextProvider = CLKSimpleTextProvider(text: period.name)
            } else {
                template.headerTextProvider = CLKSimpleTextProvider(text: "")
                template.body1TextProvider = CLKSimpleTextProvider(text: "")
            }

            return template

        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()

            if blank {
                template.textProvider = CLKSimpleTextProvider(text: "--")
                return template
            }
            
            if let period = schedule.getClass(from: date) {
                template.textProvider = CLKRelativeDateTextProvider(date: period.finishDate, style: .natural, units: .minute)
            } else {
                template.textProvider = CLKSimpleTextProvider(text: "")
            }

            return template
        default:
            return nil
        }
    }
    
    // MARK: WatchKit functions
    
    // supports backwards and forwards for seeing schedule
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }

    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if let template = complicationTemplate(complication) {
           handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }

    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(complicationTemplate(complication, from: Date(), blank: true))
    }
    
    // makes timeline for the day
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var timelineEntires = [CLKComplicationTimelineEntry]()

        // adds start entry to disable timer when it goes before
        let padOne = schedule.start.addingTimeInterval(-1)
        timelineEntires.append(CLKComplicationTimelineEntry(date: padOne, complicationTemplate: complicationTemplate(complication, from: padOne)!))
        
        var i = 0
        
        for period in schedule.periods where i < limit {
            let timelineEntry: CLKComplicationTimelineEntry
            
            if let template = complicationTemplate(complication, from: period.finishDate) {
                timelineEntry = CLKComplicationTimelineEntry(date: period.finishDate.addingTimeInterval(-60 * period.time), complicationTemplate: template)
            } else {
                continue
            }
            
            timelineEntires.append(timelineEntry)
            i += 1
        }
        
        // adds final entry to disable timer when it goes past
        if let padTwo = schedule.periods.last?.finishDate.addingTimeInterval(1) {
            timelineEntires.append(CLKComplicationTimelineEntry(date: padTwo, complicationTemplate: complicationTemplate(complication, from: padTwo)!))
        }
        
        handler(timelineEntires)
    }
    
    // callback to after date since they use the same functions for displaying past time in time travel mode
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        getTimelineEntries(for: complication, after: date, limit: limit, withHandler: handler)
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(schedule.start.addingTimeInterval(-2))
    }
    
    // block time travel for anything after the last schedule entry
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if let finishDate = schedule.periods.last?.finishDate {
            handler(finishDate.addingTimeInterval(2)) // adds 1 min to account for last entry that disables timer
        }
    }
    
}
