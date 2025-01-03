//
//  SettingsScreen.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import KeyboardShortcuts
import SwiftUI

struct SettingsScreen: View {
  @State private var logs: [String] = []

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(logs, id: \.self) { log in
            Text(log)
              .font(.system(.body, design: .monospaced))
          }
        }
      }
    }.onAppear {
      NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didActivateApplicationNotification,
        object: nil,
        queue: .main,
        using: { notification in
          print("didActivateApplicationNotification: \(notification)")
          print("frontmost: \(NSWorkspace.shared.frontmostApplication)")
          let xoo = self.isAppTrulyFocused(bundleIdentifier: "org.videolan.vlc")
          // print("isAppTrulyFocused: \(xoo)")
          logs.append("isAppTrulyFocused: \(xoo)")

          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let xoo = self.isAppTrulyFocused(bundleIdentifier: "org.videolan.vlc")
            // print("isAppTrulyFocused: \(xoo)")
            logs.append("isAppTrulyFocused: \(xoo)")
          }
        }
      )
    }
  }

  func isAppTrulyFocused(bundleIdentifier: String) -> Bool {
    guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
          frontmostApp.bundleIdentifier == bundleIdentifier
    else {
      return false
    }

    // Create an accessibility element for the frontmost app
    let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)
    var focusedWindow: CFTypeRef?

    // Check if the app has a focused window
    let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
    if result == .success, focusedWindow != nil {
      // Additional checks can be performed here to verify window visibility
      return true
    }

    return false
  }
}
