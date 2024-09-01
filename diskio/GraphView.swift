import SwiftUI
import Charts

struct GraphView: View {
    @Binding var dataPoints: [(Double, Double, String)]
    var unit: String
    @State private var selectedDataPoint: (index: Int, dataPoint: (Double, Double, String))?

    var body: some View {
        HStack {
            DiskIOChart(dataPoints: $dataPoints, selectedDataPoint: $selectedDataPoint, unit: unit)
                .padding()
                .background(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .cornerRadius(5)
        }
        .padding(10)
        .background(Color(red: 24/255, green: 0/255, blue: 51/255).opacity(0.5))
        .cornerRadius(5)
    }
}

struct DiskIOChart: View {
    @Binding var dataPoints: [(Double, Double, String)]
    @Binding var selectedDataPoint: (index: Int, dataPoint: (Double, Double, String))?
    var unit: String

    var body: some View {
        VStack(alignment: .trailing) {
            Text(unit)
                .foregroundColor(.white)
                .padding(.leading)
                .padding(.bottom)

            if #available(macOS 13.0, *) {
                Chart {
                    ForEach(dataPoints.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Index", index),
                            y: .value("Write Speed", dataPoints[index].0)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color(red: 84/255, green: 150/255, blue: 233/255))
                        .symbol(by: .value("Type", "Write"))
                        
                        LineMark(
                            x: .value("Index", index),
                            y: .value("Read Speed", dataPoints[index].1)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color(red: 235/255, green: 90/255, blue: 90/255))
                        .symbol(by: .value("Type", "Read"))
                        
                        if let selected = selectedDataPoint, selected.index == index {
                            PointMark(
                                x: .value("Index", index),
                                y: .value("Write Speed", dataPoints[index].0)
                            )
                            .foregroundStyle(Color(red: 84/255, green: 150/255, blue: 233/255))
                            .symbol(.circle)
                            .symbolSize(100)
                            
                            PointMark(
                                x: .value("Index", index),
                                y: .value("Read Speed", dataPoints[index].1)
                            )
                            .foregroundStyle(Color(red: 235/255, green: 90/255, blue: 90/255))
                            .symbol(.circle)
                            .symbolSize(100)
                            
                            PointMark(
                                x: .value("Index", index),
                                y: .value("Write Speed", dataPoints[index].0)
                            )
                            .annotation(position: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Write: \(dataPoints[index].0, specifier: "%.2f") \(unit)")
                                        .foregroundColor(Color(red: 84/255, green: 150/255, blue: 233/255))
                                    Text("Read: \(dataPoints[index].1, specifier: "%.2f") \(unit)")
                                        .foregroundColor(Color(red: 235/255, green: 90/255, blue: 90/255))
                                    Text("Time: \(dataPoints[index].2)")
                                        .foregroundColor(.white)
                                }
                                .font(.caption)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(4)
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...(maxSpeed * 1.1))
                .chartXAxis { xAxisConfiguration }
                .chartYAxis { yAxisConfiguration }
                .chartLegend(position: .bottom, alignment: .center, spacing: 10) {
                    HStack {
                        Label {
                            Text("Write")
                                .font(.callout)
                        } icon: {
                            Circle()
                                .fill(Color(red: 84/255, green: 150/255, blue: 233/255))
                                .frame(width: 7, height: 7)
                        }
                        Label {
                            Text("Read")
                                .font(.callout)
                        } icon: {
                            Rectangle()
                                .fill(Color(red: 235/255, green: 90/255, blue: 90/255))
                                .frame(width: 7, height: 7)
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(Color.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if #available(macOS 14.0, *) {
                                            updateSelectedDataPoint(at: value.location, proxy: proxy, geometry: geometry)
                                        }
                                    }
                                    .onEnded { _ in
                                        selectedDataPoint = nil
                                    }
                            )
                    }
                }
            }
        }
    }

    private var maxSpeed: Double {
        dataPoints.flatMap { [$0.0, $0.1] }.max() ?? 2000
    }

    @available(macOS 13.0, *)
    private var xAxisConfiguration: some AxisContent {
        AxisMarks(values: .stride(by: 1)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel() {
                Text("\(value.as(Int.self) ?? 0)")
                    .foregroundColor(.white)
            }
        }
    }

    @available(macOS 13.0, *)
    private var yAxisConfiguration: some AxisContent {
        AxisMarks(values: .stride(by: (maxSpeed * 1.1) / 4)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel() {
                Text("\(value.as(Int.self) ?? 0)")
                    .foregroundColor(.white)
            }
        }
    }

    @available(macOS 14.0, *)
    private func updateSelectedDataPoint(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        if let plotFrame = proxy.plotFrame {
            let relativeXPosition = location.x - geometry[plotFrame].origin.x
            guard relativeXPosition > 0 else { return }
            
            let index = Int((relativeXPosition / geometry[plotFrame].width) * CGFloat(dataPoints.count - 1))
            guard index >= 0 && index < dataPoints.count else { return }
            
            selectedDataPoint = (index, dataPoints[index])
        }
    }
}
