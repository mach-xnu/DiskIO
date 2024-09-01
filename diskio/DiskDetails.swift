import SwiftUI


struct DiskDetailsSection: View {
    @Binding var selectedDisk: DiskInfo?

    var body: some View {
        VStack(alignment: .leading) {
            if let disk = selectedDisk {
                VStack( spacing: 8) {
                    if !disk.name.isEmpty {
                        DetailRow(label: "Name", value: disk.name)
                    }
                    if disk.capacity > 0 {
                        DetailRow(label: "Capacity", value: disk.capacity.humanReadableSize())
                    }
                    if disk.freeSpace > 0 {
                        DetailRow(label: "Free Space", value: disk.freeSpace.humanReadableSize())
                    }
                    if !disk.fileSystem.isEmpty {
                        DetailRow(label: "File System", value: disk.fileSystem)
                    }
                    DetailRow(label: "Removable", value: disk.isRemovable ? "Yes" : "No")
                    if !disk.type.isEmpty {
                        DetailRow(label: "Type", value: disk.type)
                    }
                    if !disk.smartStatus.isEmpty {
                        DetailRow(label: "SMART Status", value: disk.smartStatus)
                    }
                    if disk.rotationRate > 0 {
                        DetailRow(label: "Rotation Rate", value: "\(disk.rotationRate) RPM")
                    }
                    if !disk.serialNumber.isEmpty {
                        DetailRow(label: "Serial Number", value: disk.serialNumber)
                    }
                    if !disk.manufacturer.isEmpty {
                        DetailRow(label: "Manufacturer", value: disk.manufacturer)
                    }
                    if !disk.model.isEmpty {
                        DetailRow(label: "Model", value: disk.model)
                    }
                    if !disk.firmwareVersion.isEmpty {
                        DetailRow(label: "Firmware Version", value: disk.firmwareVersion)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 32/255, green: 40/255, blue:109/255)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(5)
            } else {
                Text("No disk selected")
                    .foregroundColor(.secondary)
                    .padding()
            }
           
        }
        .padding(10)
        .background(Color(red: 24/255, green: 0/255, blue: 51/255).opacity(0.5))
        .cornerRadius(5)
    }
}

struct DetailRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

