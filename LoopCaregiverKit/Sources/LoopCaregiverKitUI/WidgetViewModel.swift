//
//  WidgetViewModel.swift
//  LoopCaregiver
//
//  Created by Bill Gestrich on 1/2/24.
//

import Foundation
import HealthKit
import LoopCaregiverKit
import LoopKit
import SwiftUI

public struct WidgetViewModel {
    
    public let timelineEntryDate: Date
    public let latestGlucose: NewGlucoseSample
    public let lastGlucoseChange: Double?
    public let isLastEntry: Bool
    public let glucoseDisplayUnits: HKUnit
    public let looper: Looper?
    
    public init(timelineEntryDate: Date, latestGlucose: NewGlucoseSample, lastGlucoseChange: Double? = nil, isLastEntry: Bool, glucoseDisplayUnits: HKUnit, looper: Looper?) {
        self.timelineEntryDate = timelineEntryDate
        self.latestGlucose = latestGlucose
        self.lastGlucoseChange = lastGlucoseChange
        self.isLastEntry = isLastEntry
        self.glucoseDisplayUnits = glucoseDisplayUnits
        self.looper = looper
    }
    
    public var currentGlucoseDateText: String {
        if isLastEntry {
            return ""
        }
        let elapsedMinutes: Double = timelineEntryDate.timeIntervalSince(latestGlucose.date) / 60.0
        let roundedMinutes = Int(exactly: elapsedMinutes.rounded(.up)) ?? 0
        return "\(roundedMinutes)m"
    }
    
    public var isGlucoseStale: Bool {
        return latestGlucose.date < timelineEntryDate.addingTimeInterval(-60*15)
    }
    
    public var currentGlucoseText: String {
        var toRet = ""
        let latestGlucoseValue = latestGlucose.presentableStringValue(displayUnits: glucoseDisplayUnits)
        toRet += "\(latestGlucoseValue)"
        
        if let lastGlucoseChangeFormatted = lastGlucoseChangeFormatted  {
            toRet += " \(lastGlucoseChangeFormatted)"
        }
        
        return toRet
    }
    
    public var currentGlucoseNumberText: String {
        var toRet = ""
        let latestGlucoseValue = latestGlucose.presentableStringValue(displayUnits: glucoseDisplayUnits)
        toRet += "\(latestGlucoseValue)"
        
        return toRet
    }
    
    public var lastGlucoseChangeFormatted: String? {
        
        guard let lastGlucoseChange = lastGlucoseChange else {return nil}
        
        guard lastGlucoseChange != 0 else {return nil}
        
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        
        guard let formattedGlucoseChange = formatter.string(from: lastGlucoseChange as NSNumber) else {
            return nil
        }
        
        return formattedGlucoseChange
        
    }
    
    public var currentTrendImageName: String? {
        
        guard let trend = latestGlucose.trend else {
            return nil
        }
        
        switch trend {
            
        case .up:
            return "arrow.up.forward"
        case .upUp:
            return "arrow.up"
        case .upUpUp:
            return "arrow.up"
        case .flat:
            return "arrow.right"
        case .down:
            return "arrow.down.forward"
        case .downDown:
            return "arrow.down"
        case .downDownDown:
            return "arrow.down"
        }
    }
    
    public var egvValueColor: Color {
        //return ColorType(quantity: latestGlucose.quantity).color
        let value = Int(latestGlucose.quantity.doubleValue(for: .milligramsPerDeciliter))
        
        print("Auggie: dynamicColorForValue(\(value)")
        //Auggie - define dynamic BG color
        // Auggie's dynamic color - Define the hue values for the key points
        let redHue: CGFloat = 0.0 / 360.0       // 0 degrees
        let greenHue: CGFloat = 120.0 / 360.0   // 120 degrees
        let purpleHue: CGFloat = 270.0 / 360.0  // 270 degrees
        
        var color: UIColor = UIColor.white // Default color
        
        // Define the bgLevel thresholds
        let minLevel = 55 // Use the urgent low BG value for red text
        let targetLevel = 100 // Use the target BG for green text
        let maxLevel = 180 // Use the urgent high BG value for purple text
        
        // Calculate the hue based on the bgLevel
        var hue: CGFloat
        if value <= minLevel {
            hue = redHue
        } else if value >= maxLevel {
            hue = purpleHue
        } else if value <= targetLevel {
            // Interpolate between red and green
            let ratio = CGFloat(value - minLevel) / CGFloat(targetLevel - minLevel)
            hue = redHue + ratio * (greenHue - redHue)
        } else {
            // Interpolate between green and purple
            let ratio = CGFloat(value - targetLevel) / CGFloat(maxLevel - targetLevel)
            hue = greenHue + ratio * (purpleHue - greenHue)
        }
        
        // Return the color with full saturation and brightness
        color = UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
        return Color(color)
    }
    
    var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }
    
}
