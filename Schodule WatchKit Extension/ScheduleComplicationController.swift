//
//  ScheduleComplicationController.swift
//  Schodule
//
//  Created by Nicholas Grana on 9/13/17.
//  Copyright © 2017 Nicholas Grana. All rights reserved.
//

import ClockKit

class ScheduleComplicationController: NSObject, CLKComplicationDataSource {
    
    var morningStart: Date {
        get {
            let calender = Calendar.current
            return calender.date(bySettingHour: 7, minute: 05, second: 0, of: Date())!
        }
    }
    
    // TODO: adding to next day
    lazy var schedule = {
        return Schedule(start: morningStart, classPeriodTime: 40, hallTime: 5, periods: "Intro to Crim", "Electronics 1", "Stats", "Lunch", "Calc", "APCS", "English", "GYM", "Physics")
    }()
    
    func complicationTemplate(_ complication: CLKComplication, from date: Date = Date()) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularLarge:
            print("large")
            let template = CLKComplicationTemplateModularLargeStandardBody()

            if let period = schedule.getNextClass(date: date) {
                template.headerTextProvider = CLKRelativeDateTextProvider(date: period.finishDate, style: .natural, units: [.minute])
                template.body1TextProvider = CLKSimpleTextProvider(text: period.name)
            } else {
                template.headerTextProvider = CLKSimpleTextProvider(text: "")
                template.body1TextProvider = CLKSimpleTextProvider(text: "")
            }

            return template

        case .modularSmall:
            print("small")
            let template = CLKComplicationTemplateModularSmallSimpleText()

            if let period = schedule.getNextClass(date: date) {
                template.textProvider = CLKRelativeDateTextProvider(date: period.finishDate, style: .natural, units: .minute)
            } else {
                template.textProvider = CLKSimpleTextProvider(text: "--")
            }

            return template
        default:
            return nil
        }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        if let template = complicationTemplate(complication) {
           handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        }
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if let template = complicationTemplate(complication) {
           handler(template)
        }
    }
    

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var timelineEntires = [CLKComplicationTimelineEntry]()
        
        var i = 0
        for period in schedule.periods {
            let timelineEntry: CLKComplicationTimelineEntry
            
            if let template = complicationTemplate(complication, from: period.finishDate) {
                if period.isHallway {
                    timelineEntry = CLKComplicationTimelineEntry(date: period.finishDate.addingTimeInterval(-60 * 5), complicationTemplate: template)
                } else {
                    timelineEntry = CLKComplicationTimelineEntry(date: period.finishDate.addingTimeInterval(-60 * 40), complicationTemplate: template)
                }
            } else {
                continue
            }
            
            timelineEntires.append(timelineEntry)
            i += 1
            if limit == i {
                break
            }
        }
        
        handler(timelineEntires)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        if let finishDate = schedule.periods.last?.finishDate {
            handler(finishDate)
        }
    }
    
}
