//
//  ADSSocialDateFormatter.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 13/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import DateTools
import NSDate_Time_Ago

//*********************************************************************************************************
// MARK: - Local date timezone support
//*********************************************************************************************************

private extension NSDate {
    func localDateStringWithFormat(dateFormat: String) -> String {
        // change to a readable time format and change to local time zone
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let timeStamp = dateFormatter.stringFromDate(self)
        
        return timeStamp
    }
    
    func localDateWithFormat(dateFormat: String) -> NSDate {
        // change to a readable time format and change to local time zone
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let timeStamp = dateFormatter.dateFromString(dateFormatter.stringFromDate(self))!
        
        return timeStamp
    }
}

class ADSSocialDateFormatter: NSObject {
    
    //*********************************************************************************************************
    // MARK: - Shared instance implementation
    //*********************************************************************************************************
    
    private class func dateFormatForProvider(provider: ADSSocialFeedProvider) -> String {
        switch provider {
        case ADSSocialFeedProvider.Facebook:
            return "yyyy'-'MM'-'dd'T'HH:mm:ssZ"
        case ADSSocialFeedProvider.Youtube:
            return "yyyy'-'MM'-'dd'T'HH:mm:ss.SSSZ"
        case ADSSocialFeedProvider.Instagram:
            return "yyyy'-'MM'-'dd'T'HH:mm:ssZ"
        case ADSSocialFeedProvider.WordPress:
            return "yyyy'-'MM'-'dd'T'HH:mm:ss"
        case ADSSocialFeedProvider.SoundCloud:
            return "yyyy'/'MM'/'dd HH:mm:ss Z"
        }
    }
    
    private class func dateFormatterForProvider(provider: ADSSocialFeedProvider) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = self.dateFormatForProvider(provider)
        
        switch provider {
        case ADSSocialFeedProvider.Facebook:
            break
        case ADSSocialFeedProvider.Youtube:
            break
        case ADSSocialFeedProvider.Instagram:
            break
        case ADSSocialFeedProvider.WordPress:
            formatter.timeZone = NSTimeZone(name: "UTC")
            break
        case ADSSocialFeedProvider.SoundCloud:
            break
        }
        
        return formatter
    }
    
    private class func sharedDateFormatterForProvider(provider: ADSSocialFeedProvider) -> NSDateFormatter {
        struct Static {
            static var formatterDictionary: [ADSSocialFeedProvider : NSDateFormatter] = [ADSSocialFeedProvider : NSDateFormatter]()
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.formatterDictionary[.Facebook]       = ADSSocialDateFormatter.dateFormatterForProvider(.Facebook)
            Static.formatterDictionary[.Youtube]        = ADSSocialDateFormatter.dateFormatterForProvider(.Youtube)
            Static.formatterDictionary[.Instagram]      = ADSSocialDateFormatter.dateFormatterForProvider(.Instagram)
            Static.formatterDictionary[.WordPress]      = ADSSocialDateFormatter.dateFormatterForProvider(.WordPress)
            Static.formatterDictionary[.SoundCloud]     = ADSSocialDateFormatter.dateFormatterForProvider(.SoundCloud)
        }
        return Static.formatterDictionary[provider]!
    }
    
    //*********************************************************************************************************
    // MARK: - Date formatter date-string conversion
    //*********************************************************************************************************
    
    class func dateFromString(string: String, provider: ADSSocialFeedProvider) -> NSDate? {
        let formattedDate: NSDate? = ADSSocialDateFormatter.sharedDateFormatterForProvider(provider).dateFromString(string)
        
        return formattedDate
    }
    
    class func stringFromDate(date: NSDate, provider: ADSSocialFeedProvider) -> String? {
        var formattedString: String? = ADSSocialDateFormatter.sharedDateFormatterForProvider(provider).stringFromDate(date)
        
        if formattedString != nil {
            formattedString = ADSSocialDateFormatter.stringFromString(formattedString!, provider: provider)
        }
        
        return formattedString
    }
    
    class func stringFromString(string: String, provider: ADSSocialFeedProvider) -> String? {
        let formattedDate: NSDate? = ADSSocialDateFormatter.sharedDateFormatterForProvider(provider).dateFromString(string)
        var formattedString: String?
        
        switch provider {
        case .Facebook:
            formattedString = formattedDate?.formattedAsTimeAgo()
        case .Youtube:
            formattedString = formattedDate?.timeAgoSinceNow()
            
            if formattedString == "Last week" {
                
                let dayDifference = formattedDate!.daysAgo()
                
                if dayDifference > 1 {
                    formattedString = "\(dayDifference) days ago"
                }else if dayDifference == 1 {
                    formattedString = "\(dayDifference) day ago" //i.e. 1 day ago
                }else {
                    
                    let hoursDifference = formattedDate!.hoursAgo()
                    
                    if hoursDifference > 1 {
                        formattedString = "\(hoursDifference) hours ago"
                    }else if hoursDifference == 1 {
                        formattedString = "\(hoursDifference) hour ago" //i.e. 1 hour ago
                    }else {
                        
                        let minutesDifference = formattedDate!.minutesAgo()
                        
                        if minutesDifference > 1 {
                            formattedString = "\(minutesDifference) minutes ago"
                        }else if minutesDifference == 1 {
                            formattedString = "\(minutesDifference) minute ago" //i.e. 1 minute ago
                        }else {
                            
                            formattedString = "Just now"
                        }
                    }
                    
                }
            }
            
        case .Instagram:
            let weekDifference = formattedDate!.weeksAgo()
            
            if weekDifference >= 1 {
                formattedString = "\(weekDifference)w"
            }else {
                
                let dayDifference = formattedDate!.daysAgo()
                
                if dayDifference >= 1 {
                    formattedString = "\(dayDifference)d"
                }else {
                    
                    let hourDifference = formattedDate!.hoursAgo()
                    
                    if hourDifference >= 1 {
                        formattedString = "\(Int(round(hourDifference)))h" //i.e. 59h
                    }else {
                        
                        let minuteDifference = formattedDate!.minutesAgo()
                        
                        if minuteDifference >= 1 {
                            formattedString = "\(Int(round(minuteDifference)))m" //i.e. 59m
                        }else {
                            
                            let secondDifference = formattedDate!.secondsAgo()
                            
                            formattedString = "\(Int(round(secondDifference)))s" //i.e. 59s
                        }
                    }
                    
                }
            }
        case .WordPress:
            formattedString = formattedDate?.formattedAsTimeAgo()
        case .SoundCloud:
            formattedString = formattedDate?.formattedAsTimeAgo()
        default:
            formattedString = formattedDate?.formattedAsTimeAgo()
        }
        
        
        return formattedString
    }
}
