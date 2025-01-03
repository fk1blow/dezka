//
//  AppSwitcherNavigator.swift
//  Dezka
//

import Cocoa
import Combine
import SwiftUI

protocol AppListNavigatorDelegate: AnyObject {
  func navigatorDidActivateSelectedApp(app: NSRunningApplication)
}

class AppListNavigator: AppListManagerDelegate {
  weak var delegate: AppListNavigatorDelegate?

  private let apListManager = AppListListManager()

  private var navigationAtIndex: Int = 0 {
    didSet {
      let wouldBeApp = apListManager.appList[navigationAtIndex]
      // print("wouldBeApp: \(wouldBeApp.localizedName ?? "Unknown App")")
    }
  }

  init() {
    apListManager.delegate = self

    let foo = FooSwitcher()
  }

  func navigateToNext() {
    guard navigationAtIndex < apListManager.appList.count - 1 else { return }
    navigationAtIndex += 1

    let wouldBeApp = apListManager.appList[navigationAtIndex]
    print("wouldBeApp: \(wouldBeApp.localizedName ?? "Unknown App")")
  }

  func navigaToPrevious() {
    guard navigationAtIndex > 0 else { return }
    navigationAtIndex -= 1
  }

  func navigateToFirst() {
    navigationAtIndex = 0
  }

  // func getSelectedApp() -> NSRunningApplication? {
  //   guard appSwitcherListManager.appList.indices.contains(navigationAtIndex) else { return nil }
  //   return appSwitcherListManager.appList[navigationAtIndex]
  // }

  func activateSelectedApp() {
    guard apListManager.appList.indices.contains(navigationAtIndex) else { return }
    let app = apListManager.appList[navigationAtIndex]
    app.activate(options: [.activateAllWindows])

    navigateToFirst()
  }

  func switcherListDidActivatedApp(app: NSRunningApplication) {
    delegate?.navigatorDidActivateSelectedApp(app: app)
  }
}

protocol AppListManagerDelegate: AnyObject {
  func switcherListDidActivatedApp(app: NSRunningApplication)
}

private class AppListListManager: NSObject {
  weak var delegate: AppListManagerDelegate?

  var appList: [NSRunningApplication] = []

  private var isAnimating = false

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
    // print("handleApplicationActivated: \(notification)")
    if let userInfo = notification.userInfo,
       let activatedApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      guard activatedApp.bundleIdentifier != "ro.dragostudorache.Dezka" else { return }

      // print("activatedApp: \(activatedApp.localizedName ?? "Unknown App")")
      var updatedAppList = appList.filter { $0.processIdentifier != activatedApp.processIdentifier }
      updatedAppList.insert(activatedApp, at: 0)
      appList = updatedAppList

      // delegate?.switcherListDidActivatedApp(app: activatedApp)
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
