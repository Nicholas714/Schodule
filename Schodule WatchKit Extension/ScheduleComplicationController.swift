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
            return calender.date(bySettingHour: 7, minute: 5, second: 0, of: Date())!
        }
    }
    
    lazy var schedule = {
        return Schedule(start: morningStart, classPeriodTime: 40, hallTime: 5, periods: "Intro to Crim", "Electronics 1", "Stats", "Lunch", "Calc", "APCS", "English", "GYM", "Physics")
    }()
    
    var currentCompliationTemplate: CLKComplicationTemplate {
        get {
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.ringStyle = .closed
            
            if let period = schedule.periodFromTime() {
                let left = period.endTime - period.timeLeft
                template.textProvider = CLKSimpleTextProvider(text: String(Int(left)))
                if period.isHallway {
                    template.fillFraction = Float(schedule.hallTime - left) / Float(schedule.hallTime)
                } else {
                    template.fillFraction = Float(schedule.classPeriodTime - left) / Float(schedule.classPeriodTime)
                }
            } else {
                template.textProvider = CLKSimpleTextProvider(text: "--")
                template.fillFraction = 0
            }
            
            return template
        }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: currentCompliationTemplate))
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: currentCompliationTemplate)
        handler([timelineEntry])
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: currentCompliationTemplate)
        handler([timelineEntry])
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(currentCompliationTemplate)
    }
    
}
