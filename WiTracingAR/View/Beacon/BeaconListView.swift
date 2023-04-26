//
//  BeaconListView.swift
//  WiTracingAR
//
//  Created by x on 26/11/2022.
//

import SwiftUI

struct BeaconListView: View {
    @EnvironmentObject var beaconManager:BeaconManager
    @AppStorage(Constant.AppStorageKey.IsBeaconScanEnabled) private var isBeaconScanEnabled = true
    @AppStorage(Constant.AppStorageKey.BeaconUUID) private var BeaconUUID:String = Constant.Beacon.DefaultBeaconUUID

    var body: some View {
        if isBeaconScanEnabled {
            VStack(alignment: .center) {
                if self.beaconManager.beacons.count <= 0 {
                    Text("No Beacon Found.")
                        .foregroundColor(.secondary)
                        .font(.title)
                } else {
                    List {
                        ForEach(self.beaconManager.beacons.sortByRSSI()) { beacon in
                            Section {
                                BeaconItemView(beacon: beacon)
                            }
                        }
                    }.listStyle(.insetGrouped)
                }
            }
            .onAppear(perform: self.onAppear )
            .onDisappear(perform: self.onDisappear)
        } else {
            Text("Beacon scaning is disable.")
                .foregroundColor(.secondary)
                .font(.title)
        }
    }
    
    func onAppear() {
        beaconManager.run(uuid: self.BeaconUUID)
    }
    
    func onDisappear(){
        beaconManager.pause()
    }
}
