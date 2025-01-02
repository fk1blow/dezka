//
//  RunningAppsMonitor.swift
//  Dezka
//

import Combine
import SwiftUI

class RunningAppsMonitor: ObservableObject {
  var appsWithWindows: [NSRunningApplication] = []

  init() {
    updateAppsWithWindows()

    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(appDidChange(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )

    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(appDidChange(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )

    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { notification in
      if let userInfo = notification.userInfo,
         let activatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      {
        print("activated app: \(activatedApp.localizedName ?? "Unknown App")")
      }
    }

    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didDeactivateApplicationNotification,
      object: nil,
      queue: .main
    ) { notification in
      if let userInfo = notification.userInfo,
         let deactivatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
      {
        print("deactivated app: \(deactivatedApp.localizedName ?? "Unknown App")")
      }
    }
  }

  @objc private func appDidChange(_: Notification) {
    updateAppsWithWindows()
  }

  func getAppsWithWindows() -> [NSRunningApplication] {
    let runningApps = NSWorkspace.shared.runningApplications
    print("runningApps: \(runningApps.count)")

    return runningApps.filter { app in
      guard !app.isHidden, app.activationPolicy == .regular else {
        return false // Exclude hidden/system apps
      }
      // This currently fails on runtime, so disregar it for now
      // return hasWindows(runningApp: app)
      return true
    }
  }

  func hasWindows(runningApp: NSRunningApplication) -> Bool {
    guard
      let appElement = AXUIElementCreateApplication(runningApp.processIdentifier) as AXUIElement?
    else {
      return false
    }

    var value: AnyObject?
    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &value)

    if result != .success {
      print(
        "Failed to fetch windows for app \(runningApp.bundleIdentifier ?? "Unknown"). Error code: \(result.rawValue)"
      )
      return false
    }

    if let windows = value as? [AXUIElement], !windows.isEmpty {
      return true
    }

    return false
  }

  func updateAppsWithWindows() {
    appsWithWindows = getAppsWithWindows()
    // print("Updated apps with windows: \(appsWithWindows.map { $0.bundleIdentifier ?? "Unknown" })")
    print(appsWithWindows.count)
  }

  deinit {
    // notificationCenter.removeObserver(self)
  }
}
