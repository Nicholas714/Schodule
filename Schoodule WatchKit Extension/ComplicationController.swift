//
//  SchooduleComplicationController.swift
//  Schoodule
//
//  Created by Nicholas Grana on 1/28/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
        
    var storage: Storage {
        return ExtensionDelegate.storage
    }
    
    var todayEvents: [Event] {
        return ExtensionDelegate.getTodayEvents()
    }
    
    // given a date and compliation type, this will send back the current complication template
    func complicationTemplate(_ complication: CLKComplication, from date: Date? = nil) -> CLKComplicationTemplate? {
        print("UPDATING COMPLICATIONS")
        
        var complicationType: ComplicationStore.PeriodComplication = .blank
        var dateProvider: CLKRelativeDateTextProvider? = nil
        var eventProvider: Event? = nil
        var location: String? = nil
        
        if let date = date {
            if let event = storage.schedule.eventFrom(date: date) {
                
                dateProvider = CLKRelativeDateTextProvider(date: event.endDate, style: .naturalAbbreviated, units: [.minute, .hour])
                eventProvider = event
                complicationType = .current
                
            } else if let nextEvent = storage.schedule.nextEventFrom(date: date) {
                let nextEventIndex = todayEvents.firstIndex(of: nextEvent)
                
                if nextEventIndex == 0 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextEvent.startDate, style: .naturalAbbreviated, units: [.minute, .hour])
                    complicationType = .first
                    location = nextEvent.location
                    
                } else if nextEventIndex == todayEvents.count - 1 {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextEvent.startDate, style: .naturalAbbreviated, units: [.minute, .hour])
                    complicationType = .last
                    location = nextEvent.location
                    
                } else {
                    
                    dateProvider = CLKRelativeDateTextProvider(date: nextEvent.startDate, style: .naturalAbbreviated, units: [.minute, .hour])
                    complicationType = .next
                    location = nextEvent.location
                    
                }
            }
        }

        return ComplicationStore(family: complication.family, event: eventProvider, dateProvider: dateProvider, location: location, type: complicationType).template
    }
    
    
    
    
    
    
    // MARK: Time Travel Support
    
    // supports backwards and forwards for seeing schedule
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.backward, .forward])
    }
    
    // block time travel for anything before the start of the schedule
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().morning)
    }
    
    // block time travel for anything after the last schedule entry
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().night)
    }
    
    
    

    
    
    
    // MARK: Timeline Creation
    
    // returns the sample template with default values when first installing complication
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(ComplicationStore(family: complication.family, event: nil, dateProvider: nil, location: "Location", type: .placeholder).template)
    }
    
    // returns the template for the current date
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        // send current template as long as it is within range of the schedule, otherwise send a blank one
        let now = Date()

        if let template = complicationTemplate(complication, from: now) {
            if let event = storage.schedule.eventFrom(date: Date()) {
                handler(CLKComplicationTimelineEntry(date: event.startDate, complicationTemplate: template))
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

        if comparision(date, Date().morning) {
            // "No Class" morning entry
            timelineEntires.append(CLKComplicationTimelineEntry(date: Date().morning, complicationTemplate: complicationTemplate(complication, from: Date().morning)!))
        }
        
        // place each event
        for event in todayEvents {
            let current = storage.schedule.eventFrom(date: Date())
            
            if let template = complicationTemplate(complication, from: event.startDate) {
                if (!comparision(date, event.startDate) && !comparision(date, event.endDate)) {

                    if sendNext && current == event {
                        if todayEvents.last != event {
                            // do not add class, but add next class entry
                            let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: event.endDate, complicationTemplate: complicationTemplate(complication, from: event.endDate.addingTimeInterval(5))!)
                            timelineEntires.append(nextClassTimelineEntry)
                        }
                    }

                    continue
                }
                
                let timelineEntry: CLKComplicationTimelineEntry
                
                timelineEntry = CLKComplicationTimelineEntry(date: event.startDate, complicationTemplate: template)
                timelineEntires.append(timelineEntry)
                
                // if not the last class, put an entry to tell the time until the next class
                if todayEvents.last != event {
                    let nextClassTimelineEntry = CLKComplicationTimelineEntry(date: event.endDate, complicationTemplate: complicationTemplate(complication, from: event.endDate.addingTimeInterval(5))!)
                    timelineEntires.append(nextClassTimelineEntry)
                }
            } else {
                continue
            }
        }
        
        if comparision(date, Date().night) {
            // adds final entry to disable timer when it goes past
            if let end = todayEvents.last?.endDate {
                timelineEntires.append(CLKComplicationTimelineEntry(date: end.addingTimeInterval(61), complicationTemplate: complicationTemplate(complication)!))
            }
        }
        
        handler(timelineEntires)
    }

}

