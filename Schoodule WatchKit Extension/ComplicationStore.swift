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
        .utilitarianSmallFlat: CLKComplicationTemplateUtilitarianSmallFlat()
    ]
    
    var family: CLKComplicationFamily
    var course: Course?
    var dateProvider: CLKRelativeDateTextProvider?
    var type: PeriodComplication
    
    var dateTextProvider: CLKTextProvider {
        if let dateTextProvider = dateProvider {
            return dateTextProvider
        }
        switch type {
        case .placeholder:
            return CLKSimpleTextProvider(text: "Time", shortText: "--")
        case .blank:
            return CLKSimpleTextProvider(text: "", shortText: "")
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
            let name = course!.name
            
            if name.count > 5 {
                let shortIndex = name.index(name.startIndex, offsetBy: 5)
                return CLKSimpleTextProvider(text: name, shortText: String(name[..<shortIndex]))
            }
            return CLKSimpleTextProvider(text: course!.name)
        case .placeholder:
            return CLKSimpleTextProvider(text: "Class")
        case .blank:
            return CLKSimpleTextProvider(text: "")
        }
    }
    
    var template: CLKComplicationTemplate? {
        guard let template = ComplicationStore.familyTemplates[family] else {
            return nil
        }
        
        template.tintColor = course?.gradient.darkColor
    
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
            
            if let location = course?.location {
                template.body2TextProvider = CLKSimpleTextProvider(text: location)
            } else {
                template.body2TextProvider = CLKSimpleTextProvider(text: "")
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
        
        return template
    }
 
}
