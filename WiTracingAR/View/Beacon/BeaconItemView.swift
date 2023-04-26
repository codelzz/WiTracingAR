//
//  BeaconItemView.swift
//  WiTracingAR
//
//  Created by x on 26/11/2022.
//

import SwiftUI
import Charts

struct BeaconItemView: View {
    @ObservedObject var beacon: Beacon
    var body: some View {
        VStack {
            BeaconItemHeaderView(beacon: beacon)
            Divider()
            BeaconItemRSSIChartView(beacon: beacon)
        }.padding(.all, 10)
    }
}

struct BeaconItemHeaderView: View {
    @ObservedObject var beacon:Beacon
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(beacon.id)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.5)
                Text(String(format: "x=%.2f,y=%.2f,z=%.2f", beacon.coordinate.x, beacon.coordinate.y, beacon.coordinate.z))
                    .font(.footnote)
                    .fontWeight(.thin)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if beacon.isDetectable {
                HStack(alignment: .bottom) {
                    /// speed
                    Text(String(format: "%.2f", beacon.distance))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.trailing, -5)
                    Text(String(format: "m"))
                        .font(.footnote)
                        .fontWeight(.thin)
                        .foregroundColor(.gray)
                    /// dBm
                    Text(String(format: "%d", beacon.rssi))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.trailing, -5)
                    Text(String(format: "dBm"))
                        .font(.footnote)
                        .fontWeight(.thin)
                        .foregroundColor(.gray)
                }
            } else {
                Text("N/A")
                    .font(.body)
                    .fontWeight(.thin)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct BeaconItemRSSIChartView: View {
    @ObservedObject var beacon:Beacon
    var body: some View {
        HStack {
            let minRssi = self.beacon.rssis.min()?.rssi
            let maxRssi = self.beacon.rssis.max()?.rssi
            let avgRssi = self.beacon.rssis.avg()?.rssi
            
            Chart {
                ForEach(Array(beacon.rssis.enumerated()), id: \.offset) { index, measurement in
                    PointMark(
                        x: .value("Timestamp", index),
                        y: .value("RSSI", measurement.rssi)
                    ).symbol(.circle)
                        .symbolSize(10)
                        .foregroundStyle(.red.opacity(0.7))
                }
                if let rssi = avgRssi {
                    RuleMark(
                        y:.value("Average", rssi)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(.foreground.opacity(0.5))
                    .annotation(position: .top, alignment: .leading) {
                        Text("average: \(rssi, format: .number) dBm")
                            .font(.custom("annotation", size: 10))
                            .fontWeight(.thin)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 10)
                    }
                    
                }
            }.aspectRatio(CGSize(width: 1, height: 0.4), contentMode: .fill)
                .chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: Beacon.maxRssisLen)))
                .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: Beacon.minRssi, upper: Beacon.maxRssi)))
                .chartXAxis{
                    AxisMarks(values: .stride(by: 5)) { value in
                        if value.as(Int.self)! % 25 == 0 {
                            AxisGridLine().foregroundStyle(.gray)
                            AxisTick().foregroundStyle(.gray)
                        } else {
                            AxisGridLine()
                        }
                        AxisValueLabel()
                    }
                }.chartYAxis{
                    AxisMarks(values: .stride(by: 5)) { value in
                        if value.as(Int.self)! % 25 == 0 {
                            AxisGridLine().foregroundStyle(.gray)
                            AxisTick().foregroundStyle(.gray)
                        } else {
                            AxisGridLine()
                        }
                    }
                }.padding(.trailing, -5)
            BeaconItemRSSIChartStatView(min: minRssi, max: maxRssi, avg: avgRssi)
        }
    }
}

struct BeaconItemRSSIChartStatView: View {
    let min:Int?
    let max:Int?
    let avg:Int?
    
    var body: some View {
        Chart {
            if let min = min, let max = max, let avg = avg {
                BarMark(
                    x: .value("Index", 0),
                    yStart: .value("RSSI Min", min),
                    yEnd: .value("RSSI Max", max)
                    ).opacity(0.3)
                RectangleMark(
                    x: .value("Index", 0),
                    y: .value("RSSI Avg", avg),
                    height: 2
                )
            }
        }.chartXScale(domain: ClosedRange(uncheckedBounds: (lower: 0, upper: Beacon.maxRssisLen)))
            .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: Beacon.minRssi, upper: Beacon.maxRssi)))
            .chartYAxis{
                AxisMarks(values: .stride(by: 5)) { value in
                    if value.as(Int.self)! % 25 == 0 {
                        AxisGridLine().foregroundStyle(.gray)
                        AxisTick().foregroundStyle(.gray)
                        AxisValueLabel()
                    } else {
                        AxisGridLine()
                    }
                }
            }
    }
}
