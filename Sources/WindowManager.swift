import ApplicationServices
import Cocoa

@main
struct WindowManager {
    static func main() {
        print("Starting WindowManager...")

        // 1. Check Accessibility Permissions
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true]
        guard AXIsProcessTrustedWithOptions(options as CFDictionary) else {
            print("Permissions not granted. Please enable Accessibility in System Settings.")
            exit(1)
        }

        // 2. Setup Key Listener
        // We call the function we created in KeyHandler.swift
        guard let eventTap = KeyHandler.setupEventTap() else {
            print("Failed to create event tap.")
            exit(1)
        }

        // 3. Connect the Event Tap to the Main Run Loop
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        // 4. Print Instructions
        print("Running!")
        print("- [Cmd + Opt + L]: Maximize")
        print("- [Cmd + Opt + ←]: Snap Left")
        print("- [Cmd + Opt + →]: Snap Right")
        print("- [Ctrl + Opt + Cmd + →]: Move to Next Display")

        // 5. Keep the app alive forever
        CFRunLoopRun()
    }
}
