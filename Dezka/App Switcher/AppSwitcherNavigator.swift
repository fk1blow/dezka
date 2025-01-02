//
//  AppSwitcherNavigator.swift
//  Dezka
//

import Combine
import SwiftUI

protocol AppSwitcherNavigatorDelegate: AnyObject {
  //
}

class AppSwitcherNavigator {
  private let appSwitcherListManager = AppSwitcherListManager()
  private var navigationAtIndex: Int = 0 {
    didSet {
      // print("navigationAtIndex: \(navigationAtIndex)")
      let wouldBeApp = appSwitcherListManager.appList[navigationAtIndex]
      // print("wouldBeApp: \(wouldBeApp.localizedName ?? "Unknown App")")
    }
  }

  func navigateToNext() {
    guard navigationAtIndex < appSwitcherListManager.appList.count - 1 else { return }
    // print("navigateToNext")
    navigationAtIndex += 1
  }

  func navigaToPrevious() {
    guard navigationAtIndex > 0 else { return }
    // print("navigaToPrevious")
    navigationAtIndex -= 1
  }

  func navigateToFirst() {
    navigationAtIndex = 0
  }

  func getSelectedApp() -> NSRunningApplication? {
    guard appSwitcherListManager.appList.indices.contains(navigationAtIndex) else { return nil }
    return appSwitcherListManager.appList[navigationAtIndex]
  }
}

private class AppSwitcherListManager {
  var appList: [NSRunningApplication] = [] {
    didSet {
      // print("appList: \(appList.map { $0.localizedName })")
    }
  }

  init() {
    appList = getAppsWithWindows()
    // print(appList.map { $0.localizedName })

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

    return runningApps
      .filter { $0.bundleIdentifier != "ro.dragostudorache.Dezka" }
      .filter { app in
        guard !app.isHidden, app.activationPolicy == .regular else {
          return false // Exclude hidden/system apps
        }
        // This currently fails on runtime, so disregar it for now
        // return hasWindows(runningApp: app)
        return true
      }
  }
}
