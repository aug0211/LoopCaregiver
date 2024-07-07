//
//  ColorType.swift
//
//
//  Created by Bill Gestrich on 1/22/24.
//

import HealthKit
import NightscoutKit
import SwiftUI

public enum ColorType: Int, CaseIterable, Comparable {
    
    case gray
    case green
    case yellow
    case red
    case clear
    case purple
    case mint
    case teal
    case cyan
    case indigo
    case blue
    case orange
    
    public init(quantity: HKQuantity) {
        let glucose = quantity.doubleValue(for:.milligramsPerDeciliter)
        switch glucose {
        case -Double.infinity..<55:
            self = ColorType.red
        case 55..<70:
            self = ColorType.orange
        case 70..<80:
            self = ColorType.yellow
        case 80..<100:
            self = ColorType.green
        case 100..<120:
            self = ColorType.mint
        case 120..<140:
            self = ColorType.blue
        case 140..<180:
            self = ColorType.indigo
        case 180...:
            self = ColorType.purple
        default:
            assertionFailure("Unexpected quantity: \(quantity)")
            self = ColorType.gray
        }
    }
    
    //Auggie - code for color based on BG number
    func dynamicColorForValue(_ value: Int) -> Color {
        print("Auggie: dynamicColorForValue(\(value)")
        //Auggie - define dynamic BG color
        // Auggie's dynamic color - Define the hue values for the key points
        let redHue: CGFloat = 0.0 / 360.0       // 0 degrees
        let greenHue: CGFloat = 120.0 / 360.0   // 120 degrees
        let purpleHue: CGFloat = 270.0 / 360.0  // 270 degrees
        
        var color: UIColor = UIColor.white // Default color
        
        // Define the bgLevel thresholds
        let minLevel = 55 // Use the urgent low BG value for red text
        let targetLevel = 90 // Use the target BG for green text
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
    
    public var color: Color {
        switch self {
        case .gray:
            return Color.gray
        case .green:
            return Color.green
        case .yellow:
            return Color.yellow
        case .red:
            return Color.red
        case .clear:
            return Color.clear
        case .purple:
            return Color.purple
        case .mint:
            return Color.mint
        case .teal:
            return Color.teal
        case .cyan:
            return Color.cyan
        case .indigo:
            return Color.indigo
        case .blue:
            return Color.blue
        case .orange:
            return Color.orange
        }
    }
    
    public static func membersAsRange() -> ClosedRange<ColorType> {
        return ColorType.allCases.first!...ColorType.allCases.last!
    }
    
    //Comparable
    public static func < (lhs: ColorType, rhs: ColorType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
}
