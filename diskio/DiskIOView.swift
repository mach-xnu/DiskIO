import SwiftUI

struct DiskIOView: View {
    @State private var writeSpeed: Double = 0
    @State private var readSpeed: Double = 0
    @State private var isTesting: Bool = false
    @State private var results: [String: [String: (write: Double, read: Double)]] = [:]
    @State private var selectedTestSize: Int = 2 * 1024 * 1024 * 1024
    @State private var selectedTestCount: Int = 1
    @State private var selectedUnit: String = "MB/s"
    @State private var lastUsedUnit: String = "MB/s"
    @State private var dataPoints: [(Double, Double, String)] = []
    @State private var selectedDisk: DiskInfo?
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var originalWriteSpeed: Double = 0
    @State private var originalReadSpeed: Double = 0
    @State private var originalDataPoints: [(Double, Double, String)] = []

    let testSizes = [
        "16 MiB": 16 * 1024 * 1024,
        "32 MiB": 32 * 1024 * 1024,
        "64 MiB": 64 * 1024 * 1024,
        "128 MiB": 128 * 1024 * 1024,
        "256 MiB": 256 * 1024 * 1024,
        "512 MiB": 512 * 1024 * 1024,
        "1 GiB": 1 * 1024 * 1024 * 1024,
        "2 GiB": 2 * 1024 * 1024 * 1024,
        "4 GiB": 4 * 1024 * 1024 * 1024,
        "8 GiB": 8 * 1024 * 1024 * 1024,
        "16 GiB": 16 * 1024 * 1024 * 1024,
        "32 GiB": 32 * 1024 * 1024 * 1024,
        "64 GiB": 64 * 1024 * 1024 * 1024
    ]

    let testCounts = Array(1...10)
    let units = ["MB/s", "GB/s", "KB/s", "IOPS"]

    var maxValues: [String: Double] {
        return [
            "MB/s": 4000,
            "GB/s": 4,
            "KB/s": 4000000,
            "IOPS": 10000000,
        ]
    }

    @State private var disks: [DiskInfo] = []

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    if geometry.size.width > 800 {
                        mainContent
                    } else {
                        mainContentWrapped
                    }
                }
                .padding()
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .onAppear {
                    self.disks = DiskManager.getWritableDisks()
                    if !self.disks.isEmpty {
                        self.selectedDisk = self.disks[0]
                    }
                }
            }
        }
    }

    private var headerView: some View {
        Text("Disk I/O Performance")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
            .foregroundColor(.white)
    }

    private var mainContent: some View {
        HStack(spacing: 20) {
            leftPanel
            rightPanel
        }
    }

    private var mainContentWrapped: some View {
        VStack(spacing: 20) {
            leftPanel
            rightPanel
        }
    }

    private var leftPanel: some View {
        VStack(spacing: 20) {
            speedGauges
            StartButton(isTesting: $isTesting, action: startTest)
            VStack {
                diskSelectionSection
                testConfigurationSection
            }
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
                
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
    }

    private var rightPanel: some View {
        VStack {
            realTimeGraph
            resultsSection
            DiskDetailsSection(selectedDisk: $selectedDisk)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
    }

    private var speedGauges: some View {
        HStack(spacing: 16) {
            GaugeView(title: "WRITE", speed: $writeSpeed, maxValue: maxValues[selectedUnit] ?? 2000, unit: selectedUnit)
            GaugeView(title: "READ", speed: $readSpeed, maxValue: maxValues[selectedUnit] ?? 2000, unit: selectedUnit)
        }
    }

    private var diskSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Disk")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Picker("Select Disk", selection: $selectedDisk) {
                ForEach(disks) { disk in
                    Text("\(disk.name) (\(disk.path))").tag(disk as DiskInfo?)
                }
            }
            .labelsHidden()
            .frame(width: 250)
            .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.5), value: selectedDisk)
        .padding(.bottom, 10)
    }

    private var testConfigurationSection: some View {
        VStack(alignment: .center, spacing: 16) {
            configurationPicker(title: "Size", selection: $selectedTestSize) {
                ForEach(testSizes.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                    Text(key).tag(value)
                }
            }

            configurationPicker(title: "Count", selection: $selectedTestCount) {
                ForEach(testCounts, id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }

            configurationPicker(title: "Unit", selection: $selectedUnit) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: selectedTestSize)
    }

    private func configurationPicker<SelectionValue: Hashable, Content: View>(
        title: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Picker(title, selection: selection) {
                content()
            }
            .labelsHidden()
            .frame(width: 200)
            .onChange(of: selection.wrappedValue) { newValue in
                if title == "Unit" {
                    convertSpeeds()
                }
            }
        }
    }

    private var realTimeGraph: some View {
        GraphView(dataPoints: $dataPoints, unit: selectedUnit)
            .frame(height: 250)
    }

    private var resultsSection: some View {
        ResultsView(results: results, unit: selectedUnit)
            .frame(height: 200)
    }

    private func convertSpeeds() {
        if selectedUnit == "IOPS" {
            // switching to IOPS from MB/s, KB/s, or GB/s
            if lastUsedUnit != "IOPS" {

                writeSpeed = 0
                readSpeed = 0
                dataPoints = []
                results = [:]
            } else {
                writeSpeed = originalWriteSpeed
                readSpeed = originalReadSpeed
                dataPoints = originalDataPoints
            }
        } else {
            if lastUsedUnit == "IOPS" {

                writeSpeed = 0
                readSpeed = 0
                dataPoints = []
                results = [:]
            } else {
                let conversionFactor: Double
                switch selectedUnit {
                case "GB/s":
                    conversionFactor = 1 / 1024.0
                case "KB/s":
                    conversionFactor = 1024.0
                default:
                    conversionFactor = 1.0
                }

                writeSpeed = originalWriteSpeed * conversionFactor
                readSpeed = originalReadSpeed * conversionFactor

                dataPoints = originalDataPoints.map { ($0.0 * conversionFactor, $0.1 * conversionFactor, $0.2) }

                results = results.mapValues { formats in
                    formats.mapValues { (write, read) in
                        (write: write * conversionFactor, read: read * conversionFactor)
                    }
                }
            }
        }
    }

    private func startTest() {
        guard let selectedDisk = selectedDisk else {
            self.errorMessage = "No disk selected. Please select a disk to test."
            self.showErrorAlert = true
            return
        }

        isTesting = true
        results = [:]
        dataPoints = []
        originalWriteSpeed = 0
        originalReadSpeed = 0
        originalDataPoints = []
        lastUsedUnit = selectedUnit

        DispatchQueue.global().async {
            let formats = ["SEQ1M QD8", "SEQ1M QD1", "RND4K QD64", "RND4K QD1"]

            var sectionResults: [String: (write: Double, read: Double)] = [:]
            for _ in 0..<selectedTestCount {
                for format in formats {
                    guard let speeds = DiskIO.performSpeedTest(disk: selectedDisk.path, format: format, fileSize: selectedTestSize, testCount: selectedTestCount, unit: selectedUnit, onUpdate: { writeSpeed, readSpeed in
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if writeSpeed > 0 {
                                    self.writeSpeed = writeSpeed
                                    self.originalWriteSpeed = writeSpeed
                                }
                                if readSpeed > 0 {
                                    self.readSpeed = readSpeed
                                    self.originalReadSpeed = readSpeed
                                }
                            }
                        }
                    }) else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Unable to write to the selected disk. Please ensure the disk is writable and try again."
                            self.showErrorAlert = true
                            self.isTesting = false
                        }
                        return
                    }

                    let (writeSpeedValue, readSpeedValue) = speeds

                    if selectedUnit == "IOPS" {
                        sectionResults[format] = (write: writeSpeedValue, read: readSpeedValue)
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.dataPoints.append((writeSpeedValue, readSpeedValue, format))
                                self.originalDataPoints.append((writeSpeedValue, readSpeedValue, format))
                            }
                        }
                    } else {
                        let conversionFactor: Double
                        switch selectedUnit {
                        case "GB/s":
                            conversionFactor = 1 / 1024.0
                        case "KB/s":
                            conversionFactor = 1024.0
                        default: // "MB/s"
                            conversionFactor = 1.0
                        }
                        let convertedWriteSpeed = writeSpeedValue * conversionFactor
                        let convertedReadSpeed = readSpeedValue * conversionFactor
                        sectionResults[format] = (write: convertedWriteSpeed, read: convertedReadSpeed)
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.dataPoints.append((convertedWriteSpeed, convertedReadSpeed, format))
                                self.originalDataPoints.append((writeSpeedValue, readSpeedValue, format))
                            }
                        }
                    }
                    Thread.sleep(forTimeInterval: 1)
                }
            }
            DispatchQueue.main.async {
                self.results["Disk IO Tests"] = sectionResults
                self.isTesting = false
            }
        }
    }

    private func chunkSizeForFormat(format: String) -> Int {
        switch format {
        case "SEQ1M QD8", "SEQ1M QD1":
            return 1 * 1024 * 1024 // 1MB
        case "RND4K QD64", "RND4K QD1":
            return 4 * 1024 // 4KB
        default:
            return 1 * 1024 * 1024 // 1MB
        }
    }
}

struct StartButton: View {
    @Binding var isTesting: Bool
    let action: () -> Void
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isTesting ? Color.gray : Color.blue)
                .frame(width: 80, height: 80)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            if !isTesting {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: 90, height: 90)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear { isAnimating = true }
            }
            
            Text(isTesting ? "Testing" : "Start")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .contentShape(Circle())
        .onTapGesture {
            action()
        }
        .disabled(isTesting)
    }
}
