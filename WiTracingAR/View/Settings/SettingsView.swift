//
//  SettingsView.swift
//  WiTracingAR
//
//  Created by x on 27/11/2022.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Form {
                ARSettingsView()
                IBeaconSettingsView()
                NetworkSettingsView()
                AboutSettingsView()
            }
        }
        
    }
}


struct ARSettingsView: View {
    @AppStorage(Constant.AppStorageKey.IsAREnabled) private var isAREnabled = true
    var body: some View {
        /// Augmented Reality (AR)
        Section(header: Text("AR"), footer: Text("Turnning on AR allow tracking position and rotation of the app accurately.")) {
            Toggle(isOn: self.$isAREnabled) {
                Text("Enable AR")
            }
        }
    }
}

struct IBeaconSettingsView: View {
    @AppStorage(Constant.AppStorageKey.IsBeaconScanEnabled) private var isBeaconScanEnabled = true
    @AppStorage(Constant.AppStorageKey.BeaconUUID) private var BeaconUUID:String = Constant.Beacon.DefaultBeaconUUID
    var body: some View {
        /// iBeacon
        Section(header: Text("IBEACON"), footer: Text("Enable beacon scanning allow device monitoring iBeacons RSSI.")) {
            Toggle(isOn: self.$isBeaconScanEnabled) {
                Text("Enable beacon scanning")
            }
            HStack {
                Text("UUID")
                Spacer()
                /// 35828EE5-8390-43AE-8457-C4C6BBC1B255
                TextField("XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", text: self.$BeaconUUID)
                    .multilineTextAlignment(.trailing)
                    .font(.footnote)
                    .foregroundColor(.gray)
                
            }
        }
    }
}

struct NetworkSettingsView: View {
    @AppStorage(Constant.AppStorageKey.IsUdpEnabled) private var isUdpEnabled = true
    @AppStorage(Constant.AppStorageKey.UdpHost) private var udpHost:String = Constant.Network.DefaultUdpHost
    @AppStorage(Constant.AppStorageKey.UdpPort) private var udpPort:Int = Constant.Network.DefaultUdpPort

    var body: some View {
        Section(header: Text("NETWORK"), footer: Text("Network configuration for data sharing.")) {
            /// Network
            Toggle(isOn: self.$isUdpEnabled) {
                Text("Enable UDP Communication")
            }
            if self.isUdpEnabled {
                HStack {
                    Text("IP Address")
                    Spacer()
                    TextField("127.0.0.1", text: self.$udpHost)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("8888", value: $udpPort, formatter: NumberFormatter())
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct AboutSettingsView: View {
    var body: some View {
        /// About
        Section(header: Text("ABOUT")) {
            HStack {
                Text("Version")
                Spacer()
                Text(Constant.About.Version)
                    .foregroundColor(.gray)
            }
        }
    }
}
