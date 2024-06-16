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
