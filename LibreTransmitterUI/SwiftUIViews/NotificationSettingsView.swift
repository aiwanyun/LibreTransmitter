//
//  NotificationSettingsView.swift
//  LibreTransmitterUI
//
//  Created by Bjørn Inge Berg on 27/05/2021.
//  Copyright © 2021 Mark Wilson. All rights reserved.
//

import SwiftUI
import Combine
import LibreTransmitter
import HealthKit





struct NotificationSettingsView: View {


    
    @State private var presentableStatus: StatusMessage?



    private var glucoseUnit: HKUnit

    private let glucoseSegments = [HKUnit.millimolesPerLiter, HKUnit.milligramsPerDeciliter]
    private lazy var glucoseSegmentStrings = self.glucoseSegments.map({ $0.localizedShortUnitString })

    public init(glucoseUnit: HKUnit) {
        if let savedGlucoseUnit = UserDefaults.standard.mmGlucoseUnit {
            self.glucoseUnit = savedGlucoseUnit
        } else {
            self.glucoseUnit = glucoseUnit
            UserDefaults.standard.mmGlucoseUnit = glucoseUnit
        }


    }


    private enum Key: String {
        //case glucoseSchedules = "no.bjorninge.glucoseschedules"

        case mmAlwaysDisplayGlucose = "no.bjorninge.mmAlwaysDisplayGlucose"
        case mmNotifyEveryXTimes = "no.bjorninge.mmNotifyEveryXTimes"
        case mmGlucoseAlarmsVibrate = "no.bjorninge.mmGlucoseAlarmsVibrate"
        case mmAlertLowBatteryWarning = "no.bjorninge.mmLowBatteryWarning"
        case mmAlertInvalidSensorDetected = "no.bjorninge.mmInvalidSensorDetected"
        //case mmAlertalarmNotifications
        case mmAlertNewSensorDetected = "no.bjorninge.mmNewSensorDetected"
        case mmAlertNoSensorDetected = "no.bjorninge.mmNoSensorDetected"

        case mmAlertSensorSoonExpire = "no.bjorninge.mmAlertSensorSoonExpire"


        case mmShowPhoneBattery = "no.bjorninge.mmShowPhoneBattery"
        case mmShowTransmitterBattery = "no.bjorninge.mmShowTransmitterBattery"

        //handle specially:
        case mmGlucoseUnit = "no.bjorninge.mmGlucoseUnit"
    }





    @AppStorage(Key.mmAlwaysDisplayGlucose.rawValue) var mmAlwaysDisplayGlucose: Bool = true
    @AppStorage(Key.mmNotifyEveryXTimes.rawValue) var mmNotifyEveryXTimes: Int = 0
    @AppStorage(Key.mmShowPhoneBattery.rawValue) var mmShowPhoneBattery: Bool = false
    @AppStorage(Key.mmShowTransmitterBattery.rawValue) var mmShowTransmitterBattery: Bool = true



    @AppStorage(Key.mmAlertLowBatteryWarning.rawValue) var mmAlertLowBatteryWarning: Bool = true
    @AppStorage(Key.mmAlertInvalidSensorDetected.rawValue) var mmAlertInvalidSensorDetected: Bool = true
    @AppStorage(Key.mmAlertNewSensorDetected.rawValue) var mmAlertNewSensorDetected: Bool = true
    @AppStorage(Key.mmAlertNoSensorDetected.rawValue) var mmAlertNoSensorDetected: Bool = true
    @AppStorage(Key.mmAlertSensorSoonExpire.rawValue) var mmAlertSensorSoonExpire: Bool = true

    @AppStorage(Key.mmGlucoseAlarmsVibrate.rawValue) var mmGlucoseAlarmsVibrate: Bool = true

    //especially handled mostly for backward compat
    @AppStorage(Key.mmGlucoseUnit.rawValue) var mmGlucoseUnit: String = ""


    @State var notifyErrorState = FormErrorState()

    @State private var favoriteGlucoseUnit = 0

    static let formatter = NumberFormatter()


    var body: some View {
        List {
            
            Section(header: Text("Glucose Notification visibility") ) {
                Toggle("Always Notify Glucose", isOn: $mmAlwaysDisplayGlucose)

                HStack {
                    Text("Notify per reading")
                    TextField("", value: $mmNotifyEveryXTimes, formatter: Self.formatter)
                        .multilineTextAlignment(.center)
                        .disabled(true)
                        .frame(minWidth: 15, maxWidth: 60)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Stepper("Value", value: $mmNotifyEveryXTimes, in: 0...9)
                        .labelsHidden()

                }.clipped()

                Toggle("Adds Phone Battery", isOn: $mmShowPhoneBattery)
                Toggle("Adds Transmitter Battery", isOn: $mmShowTransmitterBattery)
                Toggle("Also vibrate", isOn: $mmGlucoseAlarmsVibrate)

            }
            Section(header: Text("Additional notification types")) {
                Toggle("Low battery", isOn:$mmAlertLowBatteryWarning)
                Toggle("Invalid sensor", isOn:$mmAlertInvalidSensorDetected)
                Toggle("Sensor change", isOn:$mmAlertNewSensorDetected)
                Toggle("Sensor not found", isOn:$mmAlertNoSensorDetected)
                Toggle("Sensor expires soon", isOn:$mmAlertSensorSoonExpire)

            }

            Section(header: Text("Misc")) {


                HStack {
                    Text("Unit override")
                    Picker(selection: $favoriteGlucoseUnit, label: Text("Unit override")) {
                        Text(HKUnit.millimolesPerLiter.localizedShortUnitString).tag(0)
                        Text(HKUnit.milligramsPerDeciliter.localizedShortUnitString).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .clipped()
                }
            }
            .onAppear {
                favoriteGlucoseUnit = glucoseSegments.firstIndex(of: glucoseUnit) ?? 0
            }
            .onChange(of: favoriteGlucoseUnit){ newValue in
                let newUnit = glucoseSegments[newValue]
                if newUnit == HKUnit.milligramsPerDeciliter {
                    mmGlucoseUnit = "mgdl"
                } else if newUnit == HKUnit.millimolesPerLiter {
                    mmGlucoseUnit = "mmol"
                }

            }


        }
        .listStyle(InsetGroupedListStyle())
        .alert(item: $presentableStatus) { status in
            Alert(title: Text(status.title), message: Text(status.message) , dismissButton: .default(Text("Got it!")))
        }

        .navigationBarTitle("Notification Settings")

    }




}


struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView(glucoseUnit: HKUnit.millimolesPerLiter)
    }
}
