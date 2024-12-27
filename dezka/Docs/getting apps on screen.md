# Getting open apps

While this works it can't read/fetch the opened apps that
are have windows open on other workspaces(than this current one).

```swift
//
//  ContentView.swift
//  cazhan
//
//  Created by Dragos Tudorache on 22.12.2024.
//

import AppKit
import ApplicationServices
import SwiftUI

struct AppInfo: Identifiable {
  let id = UUID()
  let name: String
  let icon: NSImage?
}

let kAXVisibleAttribute: CFString = "AXVisible" as CFString

struct ContentView: View {
  @State private var openApps: [AppInfo] = []

  var body: some View {
    VStack {
      Text("Open Apps with Windows")
        .font(.headline)

      Button("Open AccessabilityConfig") {
        NSWorkspace.shared.open(
          URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        )
      }

      List(openApps) { app in
        HStack {
          if let icon = app.icon {
            Image(nsImage: icon)
              .resizable()
              .frame(width: 32, height: 32)
              .clipShape(RoundedRectangle(cornerRadius: 6))
          }
          Text(app.name)
        }
      }
      .onAppear {
        requestAccessibilityPermissions()
        fetchRunningApps()
        // fetchOpenApps()
      }
    }
    .padding()
  }

  private func requestAccessibilityPermissions() {
    let options: [String: AnyObject] = [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true as CFBoolean
    ]
    let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

    if !isTrusted {
      print("Accessibility permissions are not granted. Please enable them in System Preferences.")
    } else {
      fetchOpenApps()
    }
  }

  // Note: it seems that this function only gets the apps that are in this workspace
  private func fetchOpenApps() {
    let workspace = NSWorkspace.shared
    let apps = workspace.runningApplications

    let appsWithWindows = apps.compactMap { app -> AppInfo? in
      //   print(app.localizedName)
      guard let appName = app.localizedName,
        app.isActive || hasVisibleWindows(app: app)
      else {
        return nil
      }

      return AppInfo(name: appName, icon: app.icon)
    }

    openApps = appsWithWindows
  }

  private func hasVisibleWindows(app: NSRunningApplication) -> Bool {
    let kAXVisibleAttribute: CFString = "AXVisible" as CFString
    let kAXPositionAttribute: CFString = "AXPosition" as CFString
    let kAXSizeAttribute: CFString = "AXSize" as CFString

    // Check if the process is trusted for accessibility operations
    let options: [String: AnyObject] = [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true as CFBoolean
    ]
    let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

    if !isTrusted {
      print("Accessibility permissions are not granted. Please enable them in System Preferences.")
      return false
    }

    // Create an accessibility element for the application
    let axApp = AXUIElementCreateApplication(app.processIdentifier)

    // Prepare a variable to store the result
    var value: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &value)

    // Log the result of the AXUIElementCopyAttributeValue call
    if result != .success {
      //   print(
      //     "Failed to copy attribute value for app: \(app.localizedName ?? "Unknown"), result: \(result.rawValue)"
      //   )
      return false
    }

    // Ensure the result is successful and value is an array
    guard let windowArray = value as? [AXUIElement] else {
      //   print(
      //     "Failed to get windows for app: \(app.localizedName ?? "Unknown"). Value: \(String(describing: value))"
      //   )
      return false
    }

    if windowArray.count == 0 {
      return false
    }

    print("App \(app.localizedName ?? "Unknown") has \(windowArray.count) windows.")

    // Check if any window is visible
    for window in windowArray {
      var isVisible: CFTypeRef?
      let visibleResult = AXUIElementCopyAttributeValue(window, kAXVisibleAttribute, &isVisible)
      if visibleResult == .success, let isVisibleBool = isVisible as? Bool {
        print("Window visibility for app \(app.localizedName ?? "Unknown"): \(isVisibleBool)")
        if isVisibleBool {
          print("App \(app.localizedName ?? "Unknown") has a visible window.")
          return true
        }
      } else {
        print(
          "Failed to get visibility attribute for a window of app: \(app.localizedName ?? "Unknown"), result: \(visibleResult.rawValue)"
        )

        // Fallback: Check if the window has a valid position and size
        var position: CFTypeRef?
        var size: CFTypeRef?
        let positionResult = AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &position)
        let sizeResult = AXUIElementCopyAttributeValue(window, kAXSizeAttribute, &size)

        if positionResult == .success, sizeResult == .success, position != nil, size != nil {
          print("App \(app.localizedName ?? "Unknown") has a window with valid position and size.")
          return true
        } else {
          print(
            "Failed to get position or size attribute for a window of app: \(app.localizedName ?? "Unknown")"
          )
        }
      }
    }

    print("App \(app.localizedName ?? "Unknown") has no visible windows.")
    return false
  }

}

#Preview {
  ContentView()
}
```

## Accesibility
