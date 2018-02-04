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
        return (WKExtension.shared().delegate as! ExtensionDelegate).schoodule
    }
    
    // shorthand for first period time of the day
    var scheduleStart: Date? {
        return schoodule.periods.first?.start.date.addingTimeInterval(-600) // 10 minutes to begining next class
    }
    
    // shorthand for last period time of the day
    var scheduleEnd: Date? {
        return schoodule.periods.last?.end.date
    }

    // blank template
    func blankTemplate(_ complication: CLKComplication) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "")
            template.body1TextProvider = CLKSimpleTextProvider(text: "")
            return template
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "--")
            return template
        default:
            return nil
        }
    }
    
    // given a date and compliation type, this will send back the current complication template
    func complicationTemplate(_ complication: CLKComplication, from date: Date = Date(), blank: Bool = false) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            
            if blank {
                template.headerTextProvider = CLKSimpleTextProvider(text: "Time")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Class")
                return template
            }
            
            if let period = schoodule.classFrom(date: date) {
                template.headerTextProvider = CLKRelativeDateTextProvider(date: period.end.date, style: .natural, units: [.minute])
                template.body1TextProvider = CLKSimpleTextProvider(text: period.className)
            } else {
                if let nextClass = schoodule.nextClassFrom(date: date) {
                    if schoodule.index(of: nextClass) == 0 {
                        template.headerTextProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute])
                        template.body1TextProvider = CLKSimpleTextProvider(text: "First Class")
                    } else {
                        if schoodule.index(of: nextClass) == schoodule.unsortedPeriods.count - 1 {
                            template.headerTextProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute])
                            template.body1TextProvider = CLKSimpleTextProvider(text: "Last Class")
                        } else {
                            template.headerTextProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute])
                            template.body1TextProvider = CLKSimpleTextProvider(text: "Next Class")
                        }
                        
                    }
                } else {
                    template.headerTextProvider = CLKSimpleTextProvider(text: "")
                    template.body1TextProvider = CLKSimpleTextProvider(text: "")
                }
                
            }
            
            return template
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            
            if blank {
                template.textProvider = CLKSimpleTextProvider(text: "--")
                return template
            }
            
            if let period = schoodule.classFrom(date: date) {
                template.textProvider = CLKRelativeDateTextProvider(date: period.end.date, style: .natural, units: .minute)
            } else {
                if let nextClass = schoodule.nextClassFrom(date: date), schoodule.index(of: nextClass) != 0 {
                    template.textProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: .minute)
                } else {
                    template.textProvider = CLKSimpleTextProvider(text: "")
                }
            }
            
            return template
        default:
            return nil
        }
    }
    
    
    
    
    
    
    // MARK: Time Travel Support
    
    // supports backwards and forwards for seeing schedule
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    // callback to after date since they use the same functions for displaying past time in time travel mode
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        getTimelineEntries(for: complication, after: date, limit: limit, withHandler: handler)
    }
    
    // block time travel for anything after the last schedule entry
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(scheduleEnd?.addingTimeInterval(3)) // adds 1 min to account for last entry that disables timer
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(scheduleStart?.addingTimeInterval(-3))
    }
    
    

    
    
    
    // MARK: Timeline Creation
    
    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(complicationTemplate(complication, from: Date(), blank: true))
    }
    
    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if let template = complicationTemplate(complication) {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }
    
    // makes timeline for the day
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        guard let scheduleStart = self.scheduleStart, let scheduleEnd = self.scheduleEnd else {
            return
        }
        
        // first class
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart, complicationTemplate: complicationTemplate(complication, from: scheduleStart)!))
        
        // adds start entry to disable timer when it goes before
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart.addingTimeInterval(-3), complicationTemplate: blankTemplate(complication)!))
        
        var i = 0
        
        
        for period in schoodule.periods where i < limit {
        
            print("period date is \(period.start) and today is \(Date())")
            
            if let template = complicationTemplate(complication, from: period.start.date) {
                let timelineEntry: CLKComplicationTimelineEntry
                    
                timelineEntry = CLKComplicationTimelineEntry(date: period.start.date, complicationTemplate: template)
                timelineEntires.append(timelineEntry)
                    
                // if not the last class, put an entry to tell the time until the next class
                if scheduleEnd != period.end.date {
                    let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: period.end.date.addingTimeInterval(0.01), complicationTemplate: complicationTemplate(complication, from: period.end.date.addingTimeInterval(0.01))!)
                        timelineEntires.append(nextClassTimelineEntry)
                }
            } else {
                continue
            }
            
            i += 1
        }
        
        // adds final entry to disable timer when it goes past
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleEnd.addingTimeInterval(1), complicationTemplate: blankTemplate(complication)!))
        
        handler(timelineEntires)
    }
    
}

