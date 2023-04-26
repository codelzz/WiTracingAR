//
//  ContentView.swift
//  WiTracingAR
//
//  Created by x on 24/11/2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @StateObject private var beaconManager = BeaconManager.shared
    @StateObject private var arscnManager = ARSCNManager.shared
//    @StateObject private var arManager = ARManager.shared
    @State private var selection = 2
    
    var body: some View {
        TabView(selection: $selection){
            NavigationView {
//                ARViewUI()
                ARSCNViewUI()
            }.tabItem {
                Image(systemName: "camera.metering.center.weighted.average")
                Text("AR")
            }.tag(0)
            NavigationView {
                BeaconListView()
                    .navigationTitle("iBeacon")
            }.tabItem {
                Image(systemName: "wifi.circle.fill")
                Text("iBeacon")
            }.tag(1)
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }.tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }.tag(2)
        }
        .environmentObject(beaconManager)
        .environmentObject(arscnManager)
//        .environmentObject(arManager)
    }
}

