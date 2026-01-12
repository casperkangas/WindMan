import ApplicationServices
import Carbon  // Required for key codes (kVK_ANSI_L, etc.)
import Cocoa

@main
struct WindowManager {
    static func main() {
        print("Starting WindowManager...")

        // 1. Check Permissions
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true]
        guard AXIsProcessTrustedWithOptions(options as CFDictionary) else {
            print("Permissions not granted. Please enable Accessibility in System Settings.")
            exit(1)
        }

        // 2. Setup Global Key Listener (Event Tap)
        // We listen for KeyDown events
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard
            let eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(eventMask),
                callback: myCGEventCallback,
                userInfo: nil
            )
        else {
            print("Failed to create event tap. Ensure permissions are granted.")
            exit(1)
        }

        // 3. Add the tap to the RunLoop
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        print("Running! Press [Cmd + Option + L] to maximize the active window.")

        // 4. Keep the app alive forever
        CFRunLoopRun()
    }
}

// --- Event Callback (Must be global/C-convention) ---

func myCGEventCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // Paranoid check to ensure we only process KeyDown
    if type == .keyDown {
        let flags = event.flags
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))

        // Check for Modifier Keys: Command + Option
        let isCmd = flags.contains(.maskCommand)
        let isOption = flags.contains(.maskAlternate)

        // Check for specific key: 'L' (Code 37)
        if isCmd && isOption && keyCode == kVK_ANSI_L {
            print("Hot key detected (Cmd+Opt+L)!")

            // Perform the action
            maximizeActiveWindow()

            // Return nil to "consume" the event so the active app doesn't see it.
            return nil
        }
    }

    // Pass other events through untouched
    return Unmanaged.passUnretained(event)
}

// --- Window Logic ---

func maximizeActiveWindow() {
    guard let frontApp = NSWorkspace.shared.frontmostApplication else { return }

    let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)

    var focusedWindow: AnyObject?
    let result = AXUIElementCopyAttributeValue(
        appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)

    if result == .success, let windowElement = focusedWindow as! AXUIElement? {

        // 1. Get current window position to find the correct screen
        var positionValue: AnyObject?
        AXUIElementCopyAttributeValue(
            windowElement, kAXPositionAttribute as CFString, &positionValue)

        var currentPoint = CGPoint.zero
        if let val = positionValue as! AXValue? {
            AXValueGetValue(val, .cgPoint, &currentPoint)
        }

        // 2. Find the screen containing the window
        // Note: NSScreen coords (Bottom-Left) != Quartz/AX coords (Top-Left).
        // We use the primary screen's height to flip the Y-axis calculation.
        guard let primaryScreen = NSScreen.screens.first else { return }
        let primaryHeight = primaryScreen.frame.height

        var targetScreen: NSScreen = primaryScreen

        for screen in NSScreen.screens {
            // Convert Cocoa frame to Quartz frame for comparison
            let cocoaFrame = screen.frame
            let quartzY = primaryHeight - (cocoaFrame.origin.y + cocoaFrame.height)
            let quartzRect = CGRect(
                x: cocoaFrame.origin.x, y: quartzY, width: cocoaFrame.width,
                height: cocoaFrame.height)

            if quartzRect.contains(currentPoint) {
                targetScreen = screen
                break
            }
        }

        // 3. Calculate the "Maximized" frame
        // visibleFrame excludes the Dock and Menu Bar automatically
        let visibleFrame = targetScreen.visibleFrame

        // Convert the target visibleFrame to Quartz coordinates for the AX API
        let newX = visibleFrame.origin.x
        let newY = primaryHeight - (visibleFrame.origin.y + visibleFrame.height)
        let newWidth = visibleFrame.width
        let newHeight = visibleFrame.height

        // 4. Apply the new Position and Size
        var newPoint = CGPoint(x: newX, y: newY)
        var newSize = CGSize(width: newWidth, height: newHeight)

        if let posVal = AXValueCreate(.cgPoint, &newPoint),
            let sizeVal = AXValueCreate(.cgSize, &newSize)
        {

            AXUIElementSetAttributeValue(windowElement, kAXPositionAttribute as CFString, posVal)
            AXUIElementSetAttributeValue(windowElement, kAXSizeAttribute as CFString, sizeVal)
            if #available(macOS 10.15, *) {
                print("Maximized window on screen: \(targetScreen.localizedName)")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
