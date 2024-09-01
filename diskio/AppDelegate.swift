// AppDelegate.swift

import Cocoa
import SwiftUI

@main
struct DiskIOApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isOpaque = false
            window.backgroundColor = .clear
            
            let screenSize = NSScreen.main?.frame.size ?? NSSize(width: 1440, height: 900)
            let windowSize = NSSize(width: 1150, height: 800)
            let windowOrigin = NSPoint(x: (screenSize.width - windowSize.width) / 2,
                                       y: (screenSize.height - windowSize.height) / 2)
            
            window.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)
        }
    }
}
