//
//  AppNavigator.swift
//  Dezka
//

import Cocoa
import Combine
import SwiftUI

class AppNavigator {
  private let appListManager = AppListManager()

  private var navigationAtIndex: Int = 0 {
    didSet {
      let wouldBeApp = appListManager.appList[navigationAtIndex]
      // print("should selected app: \(wouldBeApp.localizedName ?? "Unknown App")")
    }
  }

  init() {
    print(NSWorkspace.shared.frontmostApplication)
  }

  func navigateToNext() {
    guard navigationAtIndex < appListManager.appList.count - 1 else { return }
    navigationAtIndex += 1

    let wouldBeApp = appListManager.appList[navigationAtIndex]
    print("wouldBeApp: \(wouldBeApp.localizedName ?? "Unknown App")")
  }

  func navigaToPrevious() {
    guard navigationAtIndex > 0 else { return }
    navigationAtIndex -= 1
  }

  private func resetNavigationIndex() {
    navigationAtIndex = 0
  }

  func activateSelectedApp() {
    guard appListManager.appList.indices.contains(navigationAtIndex) else { return }
    let targetApp = appListManager.appList[navigationAtIndex]

    if appCanBeSelected(app: targetApp) {
      targetApp.activate(options: [.activateIgnoringOtherApps])
    } else {
      print("App cannot be selected!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    }

    resetNavigationIndex()
  }

  func appCanBeSelected(app: NSRunningApplication) -> Bool {
    let frontmostApp = NSWorkspace.shared.frontmostApplication
    print("frontmostApp: \(frontmostApp?.localizedName ?? "Unknown App")")
    print("app: \(app.localizedName ?? "Unknown App")")

    if frontmostApp?.processIdentifier == app.processIdentifier {
      return false
    }

    return true
  }
}

private class AppListManager: NSObject {
  var appList: [NSRunningApplication] = []

  override init() {
    super.init()

    appList = getAppsWithWindows()

    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didLaunchApplicationNotification,
      object: nil,
      queue: .main,
      using: handleApplicationLaunched
    )

    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didTerminateApplicationNotification,
      object: nil,
      queue: .main,
      using: handleApplicationTerminated
    )

    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main,
      using: handleApplicationActivated
    )
  }

  private func handleApplicationLaunched(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let launchedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard launchedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      appList.append(launchedApp)
    }
  }

  private func handleApplicationTerminated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let terminatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard terminatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      appList.removeAll { $0.processIdentifier == terminatedApp.processIdentifier }
    }
  }

  private func handleApplicationActivated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let activatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard activatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }

      var updatedAppList = appList.filter { $0.processIdentifier != activatedApp.processIdentifier }
      updatedAppList.insert(activatedApp, at: 0)
      appList = updatedAppList
    }
  }

  private func getAppsWithWindows() -> [NSRunningApplication] {
    let runningApps = NSWorkspace.shared.runningApplications

    return
      runningApps
      .filter { $0.bundleIdentifier != "ro.dragostudorache.Dezka" }
      .filter { app in
        guard !app.isHidden, app.activationPolicy == .regular else {
          return false  // Exclude hidden/system apps
        }
        // This currently fails on runtime, so disregar it for now
        // return hasWindows(runningApp: app)
        return true
      }
  }
}