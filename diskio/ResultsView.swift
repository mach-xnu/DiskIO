// Results.swift

import SwiftUI

struct HeaderView: View {
    var unit: String

    var body: some View {
        HStack {
            Text("Format")
                .font(.subheadline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            Text("Write (\(unit))")
                .font(.subheadline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
            Text("Read (\(unit))")
                .font(.subheadline)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        }
        .padding(.bottom, 4)
    }
}

struct RowView: View {
    var format: String
    var writeSpeed: Double
    var readSpeed: Double

    var body: some View {
        HStack {
            Text(format)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            Text("\(writeSpeed, specifier: "%.2f")")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
            Text("\(readSpeed, specifier: "%.2f")")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        }
        .padding(4)
        .background(Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.1))

    }
}

struct SectionView: View {
    var section: String
    var formats: [String]
    var results: [String: (write: Double, read: Double)]
    var unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderView(unit: unit)

            ForEach(formats, id: \.self) { format in
                let result = results[format] ?? (write: 0, read: 0)
                RowView(format: format, writeSpeed: result.write, readSpeed: result.read)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(5)
    }
}

struct ResultsView: View {
    var formats = [
        ("Disk IO Tests", ["SEQ1M QD8", "SEQ1M QD1", "RND4K QD64", "RND4K QD1"])
    ]
    var results: [String: [String: (write: Double, read: Double)]]
    var unit: String

    var body: some View {
        VStack(spacing: 16) {
            ForEach(formats, id: \.0) { section, formats in
                SectionView(section: section, formats: formats, results: results[section] ?? [:], unit: unit)
            }
        }
        .padding(10)
        .background(Color(red: 24/255, green: 0/255, blue: 51/255).opacity(0.5))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        .cornerRadius(5)
    }
}

struct Results_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(results: [
            "Disk IO Tests": [
                "SEQ1M QD8": (write: 100, read: 200),
                "SEQ1M QD1": (write: 90, read: 180),
                "RND4K QD64": (write: 80, read: 160),
                "RND4K QD1": (write: 70, read: 140)
            ]
        ], unit: "MB/s")
    }
}
