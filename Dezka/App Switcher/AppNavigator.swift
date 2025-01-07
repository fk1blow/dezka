//
//  AppNavigator.swift
//  Dezka
//

import SwiftUI

enum AppNavigatorTraversal {
  case next
  case previous
}

struct AppNavigatorState {
  var appSearchQuery: String = ""
  var visibleApps: [NSRunningApplication] = []
  var navigationIndex: Int = 0
}

class AppNavigator: ObservableObject {
  @Published private(set) var state = AppNavigatorState()

  init() {
    state = getInitialState()

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
    guard state.navigationIndex < state.visibleApps.count - 1 else { return }
    state.navigationIndex += 1
  }

  func navigateToPrevious() {
    guard state.navigationIndex > 0 else { return }
    state.navigationIndex -= 1
  }

  func resetNavigation() {
    state.navigationIndex = 0
  }

  func activateSelectedApp() {
    guard state.visibleApps.indices.contains(state.navigationIndex) else { return }
    let targetApp = state.visibleApps[state.navigationIndex]
    targetApp.activate(options: [.activateIgnoringOtherApps])
    Debug.log("Activating app: \(targetApp.localizedName ?? "unknown")")
    resetNavigation()
  }

  private func handleApplicationLaunched(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let launchedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard launchedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      state.visibleApps.append(launchedApp)
    }
  }

  private func handleApplicationTerminated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let terminatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard terminatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }
      state.visibleApps.removeAll { $0.processIdentifier == terminatedApp.processIdentifier }
    }
  }

  private func handleApplicationActivated(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let activatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard activatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }

      var updatedAppList = state.visibleApps.filter {
        $0.processIdentifier != activatedApp.processIdentifier
      }
      updatedAppList.insert(activatedApp, at: 0)
      state.visibleApps = updatedAppList
    }
  }

  private func getInitialState() -> AppNavigatorState {
    let runningApps = NSWorkspace.shared.runningApplications

    let appsWithWindows =
      runningApps
      .filter { $0.bundleIdentifier != "ro.dragostudorache.Dezka" }
      .filter { app in
        guard !app.isHidden, app.activationPolicy == .regular else {
          return false  // Exclude hidden/system apps
        }
        return true
      }

    return AppNavigatorState(
      appSearchQuery: "",
      visibleApps: appsWithWindows,
      navigationIndex: 0
    )
  }
}
