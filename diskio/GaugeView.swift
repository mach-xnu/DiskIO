// GaugeView.swift

import SwiftUI

struct GaugeView: View {
    var title: String
    @Binding var speed: Double
    var maxValue: Double
    var unit: String

    var body: some View {
        VStack {
            ZStack {
                GaugeBackground()
                GaugeGridLines()
                GaugeNeedle(speed: speed, maxValue: maxValue)
                GaugeCenterLabel(speed: speed, unit: unit)
                GaugeTitle(title: title)
            }
            .frame(width: 200, height: 200)
            .padding()
            .padding(.bottom, -10)
            .background(
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
            )
        }
    }
}

struct GaugeCenterLabel: View {
    var speed: Double
    var unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", speed))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(unit) // Display the unit here
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .offset(y: 50)
    }
}

struct GaugeBackground: View {
    var body: some View {
        Circle()
            .trim(from: 0.25, to: 1.0)
            .stroke(
                AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: .red, location: 0.2),
                        .init(color: .yellow, location: 0.3),
                        .init(color: .green, location: 0.4),
                        .init(color: .blue, location: 0.9),
                    ]),
                    center: .center,
                    startAngle: .degrees(30),
                    endAngle: .degrees(360)
                ),
                style: StrokeStyle(lineWidth: 20, lineCap: .round)
            )
            .rotationEffect(Angle(degrees: 45))
    }
}

struct GaugeGridLines: View {
    var body: some View {
        ForEach(0..<11) { index in
            Rectangle()
                .frame(width: 2, height: 10)
                .offset(y: -85)
                .rotationEffect(Angle(degrees: Double(index) * 24.5 - 135))
                .foregroundColor(.gray)
        }
    }
}

struct GaugeNeedle: View {
    var speed: Double
    var maxValue: Double

    var body: some View {
        ZStack {
            Triangle()
                .fill(Color.red)
                .frame(width: 6, height: 100)
                .offset(y: -50)
                .rotationEffect(Angle(degrees: needleAngle()))
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
            Circle()
                .fill(Color.black)
                .frame(width: 15, height: 15)
        }
    }

    private func needleAngle() -> Double {
        return (speed / maxValue) * 270 - 135
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct GaugeTitle: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .offset(y: -35)
    }
}
