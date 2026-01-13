🖥️ WindMan for macOS
-
A lightweight, fast, and of course open-source **window manager** built purely in Swift. No bloat. No App Store fees. Just productivity.

Welcome to **WindMan**, a native macOS utility designed to keep your workspace organized with zero friction. Built for developers and power users who want keyboard-centric control over their windows without the complexity of heavy tiling window managers.

🚀 Features
-
**⚡️ Lightning Fast:** Built with native Swift and Apple's Accessibility API. Zero lag.

**🔒 Privacy First:** Runs locally. No internet connection required. No data collection.

**🔄 Built-in Updater:** Check for the latest GitHub releases directly from the menu bar.

**🛠️ Dual Snap:** Automatically snap the window _underneath_ your active window to the opposite side.

**🖥️ Multi-Monitor Support:** Throw windows instantly to your other displays.

**🎨 Clean UI:** Lives quietly in your menu bar with a custom icon and interactive guide.


⌨️ Shortcuts / Hotkeys
-
Maximize
```Cmd + Opt + L```

Snap Left (50%)
```Cmd + Opt + ←```

Snap Right (50%)
```Cmd + Opt + →```

Reset (Center 1/3)
```Cmd + Opt + R```

Move to Next Screen
```Ctrl + Opt + Cmd + →```

_Tip: You can view these anytime by clicking the **WM** icon in the menu bar and selecting "Show Guide"._


📥 Installation
-
**Option 1: The Easy Way (User)**

1. Go to the [Releases]([url](https://github.com/casperkangas/WindMan/releases)) page.

2. Download ```WindMan-v1.1.zip.```

3. Unzip and drag ```WindMan.app``` to your **Applications** folder.

4. Double-click to run.

5. **Permissions:** You will be prompted to grant **Accessibility** permissions. This is required for the app to move windows.

**Option 2: The Developer Way**

1. Clone this repo.

2. Open in VS Code or Terminal.

3. Run the local dev script (build and runs):
```./refresh.sh```

4. To create a distributable ```.app``` bundle run the package script:
```./package.sh```

⚠️ Troubleshooting Permissions
-
If the app is running but hotkeys aren't working, macOS likely has "stale" permissions (common when updating non-App Store apps).

**The Fix:**

1. Go to **System Settings** > **Privacy & Security** > **Accessibility**.

2. Find **WindMan** in the list.

3. **DO NOT** just toggle the switch. Click the **Minus (-)** button to delete it completely.

4. Restart the app (or use the new **Restart** option in the menu).

5. When prompted, grant permission again.


👨‍💻 Tech Stack
-
**Language:** Swift 6.2

**Frameworks:** Cocoa, ApplicationServices, Carbon

**Architecture:** Universal Binary (Apple Silicon & Intel)


©️ Credits
-
Created by **casperkangas** (2026)

_Open Source / MIT License_
