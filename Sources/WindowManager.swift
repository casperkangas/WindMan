import ApplicationServices
import Cocoa

@main
struct WindowManager {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

// Mark as @MainActor to ensure all UI logic happens on the main thread
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    var infoWindow: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {

        // 1. Check Permissions
        checkPermissions()

        // 2. Setup Menu Bar Icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "WM"
        }

        setupMenu()

        // 3. Setup Global Hotkeys
        setupHotkeys()

        // 4. Create the Info Window
        createInfoWindow()

        // 5. Run as "Accessory" (Menu Bar Only, No Dock Icon)
        NSApp.setActivationPolicy(.accessory)

        print("WindowManager Started. Look for 'WM' in the menu bar.")
    }

    func checkPermissions() {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true]
        if !AXIsProcessTrustedWithOptions(options as CFDictionary) {
            print("Please enable Accessibility Permissions in System Settings.")
        }
    }

    func setupHotkeys() {
        guard let eventTap = KeyHandler.setupEventTap() else {
            print("Failed to create event tap.")
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func setupMenu() {
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(title: "Show Guide", action: #selector(showGuide), keyEquivalent: "g"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func showGuide() {
        infoWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func createInfoWindow() {
        // Create a standard window, slightly larger
        let windowSize = NSRect(x: 0, y: 0, width: 350, height: 300)
        infoWindow = NSWindow(
            contentRect: windowSize,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],  // Added resizable
            backing: .buffered,
            defer: false
        )
        infoWindow.title = "WindowManager Guide"
        infoWindow.center()
        infoWindow.isReleasedWhenClosed = false  // Don't destroy when closed, just hide

        // 1. Create a Scroll View
        let scrollView = NSScrollView(frame: infoWindow.contentView!.bounds)
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]  // Resize with window
        scrollView.borderType = .noBorder

        // 2. Create the Text View
        let contentSize = scrollView.contentSize
        let content = NSTextView(
            frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        content.minSize = NSSize(width: 0.0, height: contentSize.height)
        content.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        content.isVerticallyResizable = true
        content.isHorizontallyResizable = false
        content.autoresizingMask = .width

        // Content Styling
        content.string = """
            Active Hotkeys:

            Cmd + Opt + L
            Maximize Window

            Cmd + Opt + R
            Reset (Center 1/3)

            Cmd + Opt + ←
            Snap Left (50%)

            Cmd + Opt + →
            Snap Right (50%)

            Ctrl + Opt + Cmd + →
            Move to Next Screen

            ---
            You can close this window and open it anytime from the menu bar icon.
            """
        content.isEditable = false
        content.backgroundColor = .clear
        content.font = NSFont.systemFont(ofSize: 14)
        // Add some padding
        content.textContainerInset = NSSize(width: 10, height: 10)

        // 3. Link them up
        scrollView.documentView = content
        infoWindow.contentView?.addSubview(scrollView)
    }
}