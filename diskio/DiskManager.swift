import SwiftUI
import DiskArbitration
import Foundation
import IOKit
import IOKit.storage
import IOKit.serial

let kIOMediaTypeKey = "IOMediaType"
let kIOPropertyDeviceSerialNumberKey = "Serial Number"
let kIOPropertyVendorNameKey = "Vendor Name"
let kIOPropertyProductNameKey = "Product Name"
let kIOPropertyFirmwareRevisionKey = "Firmware Revision"

struct DiskInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let capacity: Int64
    let freeSpace: Int64
    let fileSystem: String
    let isInternal: Bool
    let isRemovable: Bool
    let type: String
    let smartStatus: String
    let rotationRate: Int
    let serialNumber: String
    let manufacturer: String
    let model: String
    let firmwareVersion: String
}

class DiskManager {
    static func getWritableDisks() -> [DiskInfo] {
        var diskList = [DiskInfo]()
        
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            return diskList
        }
        
        let fileManager = FileManager.default
        let mountedVolumes = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: []) ?? []

        for volumeURL in mountedVolumes {
            if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, volumeURL as CFURL) {
                if let description = DADiskCopyDescription(disk) as? [String: AnyObject] {
                    if let bsdName = DADiskGetBSDName(disk) {
                        let volumeName = description[kDADiskDescriptionVolumeNameKey as String] as? String ?? ""
                        let capacity = description[kDADiskDescriptionMediaSizeKey as String] as? Int64 ?? 0
                        let freeSpace = (try? volumeURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage) ?? 0
                        let fileSystem = description[kDADiskDescriptionVolumeKindKey as String] as? String ?? ""
                        let isInternal = description[kDADiskDescriptionDeviceInternalKey as String] as? Bool ?? false
                        let isRemovable = description[kDADiskDescriptionMediaRemovableKey as String] as? Bool ?? false

                        // hardware details
                        let type = getDiskType(bsdName: bsdName)
                        let smartStatus = getSMARTStatus(bsdName: bsdName)
                        let rotationRate = getRotationRate(bsdName: bsdName)
                        let serialNumber = getSerialNumber(bsdName: bsdName)
                        let manufacturer = getManufacturer(bsdName: bsdName)
                        let model = getModel(bsdName: bsdName)
                        let firmwareVersion = getFirmwareVersion(bsdName: bsdName)
                        
                        let diskInfo = DiskInfo(
                            name: volumeName,
                            path: volumeURL.path,
                            capacity: capacity,
                            freeSpace: freeSpace,
                            fileSystem: fileSystem,
                            isInternal: isInternal,
                            isRemovable: isRemovable,
                            type: type,
                            smartStatus: smartStatus,
                            rotationRate: rotationRate,
                            serialNumber: serialNumber,
                            manufacturer: manufacturer,
                            model: model,
                            firmwareVersion: firmwareVersion
                        )
                        
                        // if this is the main disk
                        if volumeURL.path == "/" {
                            diskList.append(DiskInfo(
                                name: volumeName + " (Main Disk)",
                                path: NSTemporaryDirectory(),
                                capacity: capacity,
                                freeSpace: freeSpace,
                                fileSystem: fileSystem,
                                isInternal: isInternal,
                                isRemovable: isRemovable,
                                type: type,
                                smartStatus: smartStatus,
                                rotationRate: rotationRate,
                                serialNumber: serialNumber,
                                manufacturer: manufacturer,
                                model: model,
                                firmwareVersion: firmwareVersion
                            ))
                        } else if isWritableDisk(at: volumeURL.path) {
                            diskList.append(diskInfo)
                        }
                    }
                }
            }
        }
        
        return diskList
    }
    
    private static func isWritableDisk(at path: String) -> Bool {
        let fileManager = FileManager.default
        let testFilePath = (path as NSString).appendingPathComponent("testfile")
        let isWritable = (try? "test".write(toFile: testFilePath, atomically: true, encoding: .utf8)) != nil
        try? fileManager.removeItem(atPath: testFilePath)
        return isWritable
    }

    private static func getDiskType(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var diskType: String = ""
        if let type = IORegistryEntryCreateCFProperty(service, kIOMediaTypeKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            diskType = type
        }
        
        IOObjectRelease(service)
        return diskType
    }

    private static func getSMARTStatus(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var smartStatus: String = ""
        if let status = IORegistryEntryCreateCFProperty(service, "SMARTStatus" as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            smartStatus = status
        }
        
        IOObjectRelease(service)
        return smartStatus
    }

    private static func getRotationRate(bsdName: UnsafePointer<Int8>) -> Int {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return 0 }
        
        var rotationRate: Int = 0
        if let rate = IORegistryEntryCreateCFProperty(service, "RotationRate" as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? Int {
            rotationRate = rate
        }
        
        IOObjectRelease(service)
        return rotationRate
    }

    private static func getSerialNumber(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var serialNumber: String = ""
        if let serial = IORegistryEntryCreateCFProperty(service, kIOPropertyDeviceSerialNumberKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            serialNumber = serial
        }
        
        IOObjectRelease(service)
        return serialNumber
    }

    private static func getManufacturer(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var manufacturer: String = ""
        if let manufacturerValue = IORegistryEntryCreateCFProperty(service, kIOPropertyVendorNameKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            manufacturer = manufacturerValue
        }
        
        IOObjectRelease(service)
        return manufacturer
    }

    private static func getModel(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var model: String = ""
        if let modelValue = IORegistryEntryCreateCFProperty(service, kIOPropertyProductNameKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            model = modelValue
        }
        
        IOObjectRelease(service)
        return model
    }

    private static func getFirmwareVersion(bsdName: UnsafePointer<Int8>) -> String {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOBSDNameMatching(kIOMainPortDefault, 0, bsdName))
        guard service != 0 else { return "" }
        
        var firmwareVersion: String = ""
        if let firmware = IORegistryEntryCreateCFProperty(service, kIOPropertyFirmwareRevisionKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
            firmwareVersion = firmware
        }
        
        IOObjectRelease(service)
        return firmwareVersion
    }
}
