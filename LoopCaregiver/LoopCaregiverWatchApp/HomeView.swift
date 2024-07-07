//
//  HomeView.swift
//  LoopCaregiverWatchApp
//
//  Created by Bill Gestrich on 12/18/23.
//

import LoopCaregiverKit
import LoopCaregiverKitUI
import SwiftUI
import WidgetKit
    
struct HomeView: View {
    
    @ObservedObject var connectivityManager: WatchService
    @ObservedObject var accountService: AccountServiceManager
    @ObservedObject var remoteDataSource: RemoteDataServiceManager
    @ObservedObject var settings: CaregiverSettings
    @ObservedObject var looperService: LooperService
    @Environment(\.scenePhase) var scenePhase
    
    //Reduced from 1.2 to 1.16 for Stainless Steel (non ultra)
    var homeViewTextMultiplier = 1.16
    
    init(connectivityManager: WatchService, looperService: LooperService){
        self.connectivityManager = connectivityManager
        self.looperService = looperService
        self.settings = looperService.settings
        self.accountService = looperService.accountService
        self.remoteDataSource = looperService.remoteDataSource
    }
    
    var body: some View {
        HStack (spacing: 10) {
            VStack {
                //BG number
                Text(remoteDataSource.currentGlucoseSample?.presentableStringValue(displayUnits: settings.glucoseDisplayUnits) ?? "??")
                    .strikethrough(egvIsOutdated())
                    .font(.system(size: 65.0 * homeViewTextMultiplier))
                    .foregroundColor(egvValueColor())
            }
            VStack (spacing: 0) {
                HStack {
                    //Trend arrow
                    if let egv = remoteDataSource.currentGlucoseSample {
                        Image(systemName: egv.arrowImageName())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 12 * homeViewTextMultiplier)
                            .offset(.init(width: 0.0, height: 1.5 * homeViewTextMultiplier))
                    }
                    //BG delta
                    Text(lastEGVDeltaFormatted())
                        .strikethrough(egvIsOutdated())
                        .font(.system(size: 20.0 * homeViewTextMultiplier))
                }
                //Minutes since update
                Text(durSinceEGV())
                    .strikethrough(egvIsOutdated())
                    .font(.system(size: 20.0 * homeViewTextMultiplier))
            }
        }
        //Auggie - original home view implementation here
        /*
        VStack (spacing: 0) {
            //BG number
            HStack {
                Text(remoteDataSource.currentGlucoseSample?.presentableStringValue(displayUnits: settings.glucoseDisplayUnits) ?? " ")
                    .strikethrough(egvIsOutdated())
                    .font(.custom("SF Compact", fixedSize:70))
                    .foregroundColor(egvValueColor())
            }
            VStack (spacing: 10) {
                //Trend arrow
                HStack {
                    if let egv = remoteDataSource.currentGlucoseSample {
                        Image(systemName: egv.arrowImageName())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:25.0)
                            .offset(.init(width: 0.0, height: 3.0))
                    }
                    //BG delta
                    Text(lastEGVDeltaFormatted())
                        .strikethrough(egvIsOutdated())
                        .font(.custom("SF Compact", fixedSize:40))
                    
                }
                //Time since last reading in mm:ss format
                HStack {
                    Text(durSinceEGV())
                        .font(.custom("SF Compact", fixedSize:30))
                    /*
                     Text("ago")
                     .font(.custom("SF Compact", fixedSize:30))
                     */
                }
            }
        }
         */
        .navigationTitle(accountService.selectedLooper?.name ?? "Name?")
        .navigationDestination(for: String.self, destination: { _ in
            SettingsView(connectivityManager: connectivityManager, accountService: accountService, settings: settings)
        })
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: "SettingsView") {
                    Image(systemName: "gear")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await looperService.remoteDataSource.updateData()
                        reloadWidget()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
        .onChange(of: scenePhase, { oldValue, newValue in
            Task {
                await remoteDataSource.updateData()
            }
        })
    }
    
    func glucoseText() -> String {
        remoteDataSource.currentGlucoseSample?.presentableStringValue(displayUnits: settings.glucoseDisplayUnits) ?? " "
    }
    
    func lastGlucoseChange() -> Double? {
        let egvs = remoteDataSource.glucoseSamples
        guard egvs.count > 1 else {
            return nil
        }
        let lastGlucoseValue = egvs[egvs.count - 1].presentableUserValue(displayUnits: settings.glucoseDisplayUnits)
        let priorGlucoseValue = egvs[egvs.count - 2].presentableUserValue(displayUnits: settings.glucoseDisplayUnits)
        return lastGlucoseValue - priorGlucoseValue
    }
    
    func lastEGVTimeFormatted() -> String {
        guard let currentEGV = remoteDataSource.currentGlucoseSample else {
            return ""
        }
        
        return currentEGV.date.formatted(.dateTime.hour().minute())
    }
    
    //Minutes since last BG reading
    func minSinceEGV() -> String {
        guard let currentEGV = remoteDataSource.currentGlucoseSample else {
            return "0"
        }
        return String(Int(Date().timeIntervalSince(currentEGV.date)) / 60)
    }
    
    //Seconds since last BG reading
    func secSinceEGV() -> String {
        guard let currentEGV = remoteDataSource.currentGlucoseSample else {
            return "00"
        }
        let seconds = Int(Date().timeIntervalSince(currentEGV.date)) % 60
        return(String(format: "%02d", seconds))
    }
    
    //Time since last reading in mm:ss
    func durSinceEGV() -> String {
        return minSinceEGV() + ":" + secSinceEGV()
    }
    
    func egvIsOutdated() -> Bool {
        guard let currentEGV = remoteDataSource.currentGlucoseSample else {
            return true
        }
        return Date().timeIntervalSince(currentEGV.date) > 60 * 10
    }
    
    func egvValueColor() -> Color {
        if let currentEGV = remoteDataSource.currentGlucoseSample {
            //return ColorType(quantity: latestGlucose.quantity).color
            let value = Int(currentEGV.quantity.doubleValue(for: .milligramsPerDeciliter))
            
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
        } else {
            return .white
        }
    }
    
    func lastEGVDeltaFormatted() -> String {
        
        guard let lastEGVChange = self.lastGlucoseChange() else {
            return ""
        }
        
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        
        guard let formattedEGV = formatter.string(from: lastEGVChange as NSNumber) else {
            return ""
        }
        
        return formattedEGV
        
    }
    
    func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }

}

#Preview {
    let composer = ServiceComposerPreviews()
    return NavigationStack {
        let looper = composer.accountServiceManager.selectedLooper!
        let looperService = composer.accountServiceManager.createLooperService(looper: looper, settings: composer.settings)
        HomeView(connectivityManager: composer.watchService, looperService: looperService)
    }
}
