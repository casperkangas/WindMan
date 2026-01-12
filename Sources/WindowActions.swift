import ApplicationServices
import Cocoa

enum WindowSnapDirection {
    case left
    case right
    case maximize
}

struct WindowActions {

    // MARK: - Snap / Maximize
    static func snapActiveWindow(to direction: WindowSnapDirection) {
        guard let (windowElement, currentScreen) = getActiveWindowAndScreen() else { return }

        let visibleFrame = currentScreen.visibleFrame
        let primaryHeight = NSScreen.screens.first?.frame.height ?? visibleFrame.height

        // Calculate standard "Quartz" Y coordinate (flipping Cocoa's bottom-left origin)
        let standardY = primaryHeight - (visibleFrame.origin.y + visibleFrame.height)

        // Fixed Warning: Changed 'var' to 'let' because these values are constant for our current logic
        let newY: CGFloat = standardY
        let newHeight: CGFloat = visibleFrame.height

        var newX: CGFloat = 0
        var newWidth: CGFloat = 0

        switch direction {
        case .maximize:
            newX = visibleFrame.origin.x
            newWidth = visibleFrame.width
        case .left:
            newX = visibleFrame.origin.x
            newWidth = visibleFrame.width / 2
        case .right:
            newX = visibleFrame.origin.x + (visibleFrame.width / 2)
            newWidth = visibleFrame.width / 2
        }

        setWindowFrame(windowElement, x: newX, y: newY, width: newWidth, height: newHeight)
    }

    // MARK: - Move to Next Display
    static func moveActiveWindowToNextScreen() {
        guard let (windowElement, currentScreen) = getActiveWindowAndScreen() else { return }
        let screens = NSScreen.screens

        // Only proceed if we have more than one screen
        guard screens.count > 1, let currentIndex = screens.firstIndex(of: currentScreen) else {
            return
        }

        // Calculate next screen index (looping back to 0)
        let nextIndex = (currentIndex + 1) % screens.count
        let nextScreen = screens[nextIndex]

        // Move to the center of the next screen (simple "Throw" logic)
        // We calculate the top-left corner of the next screen in Quartz coordinates
        let visibleFrame = nextScreen.visibleFrame
        let primaryHeight = screens.first?.frame.height ?? 0

        let newX = visibleFrame.origin.x
        let newY = primaryHeight - (visibleFrame.origin.y + visibleFrame.height)

        // Keep current size, just move position
        var point = CGPoint(x: newX, y: newY)
        if let posVal = AXValueCreate(.cgPoint, &point) {
            AXUIElementSetAttributeValue(windowElement, kAXPositionAttribute as CFString, posVal)

            // Fixed Error: Added availability check for localizedName (macOS 10.15+)
            if #available(macOS 10.15, *) {
                print("Moved window to screen: \(nextScreen.localizedName)")
            } else {
                print("Moved window to screen index: \(nextIndex)")
            }
        }
    }

    // MARK: - Helpers

    // Helper to apply size and position
    private static func setWindowFrame(
        _ window: AXUIElement, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat
    ) {
        var point = CGPoint(x: x, y: y)
        var size = CGSize(width: width, height: height)

        if let posVal = AXValueCreate(.cgPoint, &point),
            let sizeVal = AXValueCreate(.cgSize, &size)
        {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posVal)
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeVal)
        }
    }

    // Helper to find the window and the screen it is currently on
    private static func getActiveWindowAndScreen() -> (AXUIElement, NSScreen)? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)

        var focusedWindow: AnyObject?
        if AXUIElementCopyAttributeValue(
            appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow) != .success
        {
            return nil
        }

        let windowElement = focusedWindow as! AXUIElement

        // Find current position to determine screen
        var positionValue: AnyObject?
        AXUIElementCopyAttributeValue(
            windowElement, kAXPositionAttribute as CFString, &positionValue)

        var currentPoint = CGPoint.zero
        if let val = positionValue as! AXValue? {
            AXValueGetValue(val, .cgPoint, &currentPoint)
        }

        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0

        // Find which screen contains this point
        for screen in NSScreen.screens {
            let cocoaFrame = screen.frame
            let quartzY = primaryHeight - (cocoaFrame.origin.y + cocoaFrame.height)
            let quartzRect = CGRect(
                x: cocoaFrame.origin.x, y: quartzY, width: cocoaFrame.width,
                height: cocoaFrame.height)

            if quartzRect.contains(currentPoint) {
                return (windowElement, screen)
            }
        }

        // Fallback to primary if not found
        return (windowElement, NSScreen.screens[0])
    }
}
