//
//  AppNavigator.swift
//  Dezka
//

import SwiftUI

class AppNavigator: ObservableObject {
  @Published private(set) var appListFilterQuery: String = ""
  @Published private(set) var appsList: [NSRunningApplication] = []
  @Published private(set) var navigationAtIndex: Int = 0

  init() {
    appsList = getAppsWithWindows()

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

  func navigateToNext() {
    guard navigationAtIndex < appsList.count - 1 else { return }
    navigationAtIndex += 1
  }

  func navigateToPrevious() {
    guard navigationAtIndex > 0 else { return }
    navigationAtIndex -= 1
  }

  func resetNavigation() {
    resetNavigationStart()
  }

  func activateSelectedApp() {
    guard appsList.indices.contains(navigationAtIndex) else { return }
    let targetApp = appsList[navigationAtIndex]
    targetApp.activate(options: [.activateIgnoringOtherApps])
    // Debug.log("Activating app: \(targetApp.localizedName ?? "unknown")")
    resetNavigationStart()
  }

  private func resetNavigationStart() {
    navigationAtIndex = 0
  }

  private func handleApplicationLaunched(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let launchedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard launchedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      appsList.append(launchedApp)
    }
  }

  private func handleApplicationTerminated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let terminatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard terminatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      appsList.removeAll { $0.processIdentifier == terminatedApp.processIdentifier }
    }
  }

  private func handleApplicationActivated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let activatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard activatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }

      var updatedAppList = appsList.filter {
        $0.processIdentifier != activatedApp.processIdentifier
      }
      updatedAppList.insert(activatedApp, at: 0)
      appsList = updatedAppList
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
