import Foundation

struct DiskIO {
    static var updateClosure: ((Double, Double) -> Void)?

    static let cCallback: @convention(c) (Double, Double) -> Void = { writeSpeed, readSpeed in
        DispatchQueue.main.async {
            guard let closure = DiskIO.updateClosure else { return }
            closure(writeSpeed, readSpeed)
        }
    }

    static func performSpeedTest(disk: String, format: String, fileSize: Int, testCount: Int, unit: String, onUpdate: @escaping (Double, Double) -> Void) -> (Double, Double)? {
        let path = (disk as NSString).appendingPathComponent("testfile").cString(using: String.Encoding.utf8)

        var writeSpeedResult: Double = 0.0
        var readSpeedResult: Double = 0.0

        guard isWritableDisk(disk: disk) else {
            print("Disk is not writable.")
            return nil
        }

        DiskIO.updateClosure = onUpdate

        if let path = path {
            perform_speed_test(path, Int64(fileSize), format, Int32(testCount), unit, &writeSpeedResult, &readSpeedResult, DiskIO.cCallback)
        }

        // final calculation and update
        onUpdate(writeSpeedResult, readSpeedResult)
        return (writeSpeedResult, readSpeedResult)
    }

    private static func isWritableDisk(disk: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        if fileManager.fileExists(atPath: disk, isDirectory: &isDir), isDir.boolValue {
            let testFilePath = (disk as NSString).appendingPathComponent("testfile")
            let isWritable = fileManager.isWritableFile(atPath: disk) && (try? "test".write(toFile: testFilePath, atomically: true, encoding: .utf8)) != nil
            try? fileManager.removeItem(atPath: testFilePath) // clean test file if created
            return isWritable
        }

        return false
    }
}
