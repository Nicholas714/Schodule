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
    
    func largeTemplate(title: String, body1: CLKTextProvider, body2: String, color: UIColor? = nil) -> CLKComplicationTemplateModularLargeStandardBody {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        
        template.headerTextProvider = CLKSimpleTextProvider(text: title)
        template.body1TextProvider = body1
        template.body2TextProvider = CLKSimpleTextProvider(text: body2)
        template.tintColor = color
        return template
    }

    func largeTemplate(title: String, body1: String, body2: String, color: UIColor? = nil) -> CLKComplicationTemplateModularLargeStandardBody {
        return largeTemplate(title: title, body1: CLKSimpleTextProvider(text: body1), body2: body2, color: color)
    }
    
    // given a date and compliation type, this will send back the current complication template
    func complicationTemplate(_ complication: CLKComplication, from date: Date, blank: Bool = false) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularLarge:
            
            if blank {
                return largeTemplate(title: "Class", body1: "Time", body2: "")
            }
            
            var template: CLKComplicationTemplateModularLargeStandardBody
            
            if let period = schoodule.classFrom(date: date) {
                let timeProvider = CLKRelativeDateTextProvider(date: period.end.date, style: .natural, units: [.minute, .hour])
                
                template = largeTemplate(title: period.className, body1: timeProvider, body2: "", color: period.color)
            } else {
                if let nextClass = schoodule.nextClassFrom(date: date) {
                    if schoodule.index(of: nextClass) == 0 {
                        let timeProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])

                        template = largeTemplate(title: "First Class", body1: timeProvider, body2: "")
                    } else {
                        if schoodule.index(of: nextClass) == schoodule.unsortedPeriods.count - 1 {
                            let timeProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])

                            template = largeTemplate(title: "Last Class", body1: timeProvider, body2: "")
                        } else {
                            let timeProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])
                            
                            template = largeTemplate(title: "Next Class", body1: timeProvider, body2: "")
                        }
                        
                    }
                } else {
                    template = largeTemplate(title: "", body1: "", body2: "")
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
                template.tintColor = period.color
                template.textProvider = CLKRelativeDateTextProvider(date: period.end.date, style: .natural, units: [.minute, .hour])
            } else {
                if let nextClass = schoodule.nextClassFrom(date: date), schoodule.index(of: nextClass) != 0 {
                    template.textProvider = CLKRelativeDateTextProvider(date: nextClass.start.date, style: .natural, units: [.minute, .hour])
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
        handler(scheduleEnd?.addingTimeInterval(30))
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
       handler(scheduleStart?.addingTimeInterval(-30))
    }
    
    

    
    
    
    // MARK: Timeline Creation
    
    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(complicationTemplate(complication, from: Date(), blank: true))
    }
    
    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if let template = complicationTemplate(complication, from: Date()) {
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }
    
    // makes timeline for the day
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let start = Date()
        
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        guard let scheduleStart = self.scheduleStart, let scheduleEnd = self.scheduleEnd else {
            return
        }
        
        // adds start entry to disable timer when it goes before
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart.addingTimeInterval(-20), complicationTemplate: blankTemplate(complication)!))
        
        // first class
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleStart, complicationTemplate: complicationTemplate(complication, from: scheduleStart)!))
        
        var i = 0
        
        
        for period in schoodule.periods where i < limit {
                
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
        timelineEntires.append(CLKComplicationTimelineEntry(date: scheduleEnd.addingTimeInterval(20), complicationTemplate: blankTemplate(complication)!))
        
        handler(timelineEntires)
        
        print("ttttt \(start.timeIntervalSinceNow)")
    }
    
}

