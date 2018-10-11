//
//  ComplicationStore.swift
//  Schoodule WatchKit Extension
//
//  Created by Nicholas Grana on 2/18/18.
//  Copyright © 2018 Nicholas Grana. All rights reserved.
//

import WatchKit

struct ComplicationStore {
    
    public enum PeriodComplication {
        case first
        case current
        case next
        case last
        case placeholder
        case blank
    }
    
    static var familyTemplates: Dictionary<CLKComplicationFamily, CLKComplicationTemplate> = [
        .circularSmall: CLKComplicationTemplateCircularSmallStackText(),
        .extraLarge: CLKComplicationTemplateExtraLargeStackText(),
        
        .modularLarge: CLKComplicationTemplateModularLargeStandardBody(),
        .modularSmall: CLKComplicationTemplateModularSmallStackText(),
        
        .utilitarianLarge: CLKComplicationTemplateUtilitarianLargeFlat(),
        .utilitarianSmall: CLKComplicationTemplateUtilitarianSmallFlat(),
        .utilitarianSmallFlat: CLKComplicationTemplateUtilitarianSmallFlat(),
        
        // TODO: implement
        //.graphicBezel: CLKComplicationTemplateGraphicBezelCircularText(),
        //.graphicCorner: CLKComplicationTemplateGraphicCornerStackText(),
        //.graphicCircular: CLKComplicationTemplateGraphicCircularClosedGaugeText(),
        //.graphicRectangular: CLKComplicationTemplateGraphicRectangularStandardBody()
    ]
    
    var family: CLKComplicationFamily
    var event: Event?
    var dateProvider: CLKRelativeDateTextProvider?
    var location: String?
    var type: PeriodComplication
    
    var dateTextProvider: CLKTextProvider {
        if let dateTextProvider = dateProvider {
            return dateTextProvider
        }
        switch type {
        case .placeholder:
            return CLKSimpleTextProvider(text: "Time", shortText: "--")
        case .blank:
            return CLKSimpleTextProvider(text: "", shortText: "None")
        default:
            return CLKSimpleTextProvider(text: "Time", shortText: "--")
        }
    }
    
    var periodNameProvider: CLKTextProvider {
        switch type {
        case .first:
            return CLKSimpleTextProvider(text: "First Class", shortText: "First")
        case .next:
            return CLKSimpleTextProvider(text: "Next Class", shortText: "Next")
        case .last:
            return CLKSimpleTextProvider(text: "Last Class", shortText: "Last")
        case .current:
            let name = event!.name
            
            if name.count > 5 {
                let shortIndex = name.index(name.startIndex, offsetBy: 5)
                return CLKSimpleTextProvider(text: name, shortText: String(name[..<shortIndex]))
            }
            return CLKSimpleTextProvider(text: event!.name)
        case .placeholder:
            return CLKSimpleTextProvider(text: "Class")
        case .blank:
            return CLKSimpleTextProvider(text: "No Classes")
        }
    }
    
    var template: CLKComplicationTemplate? {
        guard let template = ComplicationStore.familyTemplates[family] else {
            return nil
        }
        
        if let event = event {
            template.tintColor = UIColor(color: event.color)
        } else {
            template.tintColor = UIColor.white 
        }
    
        if let template = template as? CLKComplicationTemplateCircularSmallStackText {
            
            // circular small stack with period name as line 1 and time left on line 2
            template.line1TextProvider = periodNameProvider
            template.line2TextProvider = dateTextProvider
            
        } else if let template = template as? CLKComplicationTemplateExtraLargeStackText {
            
            // extraLarge stack with period name as line 1 and time left on line 2
            template.line1TextProvider = periodNameProvider
            template.line2TextProvider = dateTextProvider
            
        } else if let template = template as? CLKComplicationTemplateModularLargeStandardBody {
            
            // modularLarge text provider with period name as header, time left on body 1, and location on body 2
            template.headerTextProvider = periodNameProvider
            template.body1TextProvider = dateTextProvider
            
            if let location = event?.location {
                template.body2TextProvider = CLKSimpleTextProvider(text: location)
            } else {
                if let location = location {
                    template.body2TextProvider = CLKSimpleTextProvider(text: location)
                } else {
                    template.body2TextProvider = CLKSimpleTextProvider(text: "")
                }
            }
            
        } else if let template = template as? CLKComplicationTemplateModularSmallStackText {
            
            // modularSmall with period name on line 1 and time left on line 2
            template.line1TextProvider = periodNameProvider
            template.line2TextProvider = dateTextProvider
            
        } else if let template = template as? CLKComplicationTemplateUtilitarianLargeFlat {
            
            // utilitarianLarge with only the time
            template.textProvider = dateTextProvider
            
        } else if let template = template as? CLKComplicationTemplateUtilitarianSmallFlat {

            // utilitarianSmall with only the time
            template.textProvider = dateTextProvider
            
        }
        if #available(watchOS 5.0, *) {
            if let template = template as? CLKComplicationTemplateGraphicBezelCircularText {
                
                // TODO: implement
                template.textProvider = periodNameProvider
                let gauge = CLKComplicationTemplateGraphicCircularClosedGaugeText()
                gauge.centerTextProvider = dateTextProvider
                gauge.gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [.red, .green], gaugeColorLocations: [0.5, 1.0], start: event?.startDate ?? Date(), end: event?.endDate ?? Date().addingTimeInterval(60 * 60))
                template.circularTemplate = gauge
                
            } else if let template = template as? CLKComplicationTemplateGraphicCornerStackText {
                
                // TODO: implement
                
            } else if let template = template as? CLKComplicationTemplateGraphicCircularClosedGaugeText {
                
                
                
            } else if let template = template as? CLKComplicationTemplateGraphicRectangularStandardBody {
                
                // TODO: implement
                
            }
        }
            
        
        
        return template
    }
 
}
