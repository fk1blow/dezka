//
//  AppListManager.swift
//  Dezka
//

import SwiftUI

private struct AppListManagerKey: EnvironmentKey {
  static let defaultValue: AppListManager? = nil  // Default to nil to make access safer
}

extension EnvironmentValues {
  var appListManager: AppListManager? {
    get { self[AppListManagerKey.self] }
    set { self[AppListManagerKey.self] = newValue }
  }
}

class AppListManager: ObservableObject {
  @Published var runningApplications: [NSRunningApplication] = []
  @Published var selectedIndex: Int = 0

  init() {
    getRunningApplications()

    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(handleAndleApplicationDidLaunch(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )

    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(handleAndleApplicationDidTerminate(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )
  }

  func switchFocusTo(where appToFocus: NSRunningApplication) {
    // var reorderedAppList = runningApplications.filter {
    //   $0.processIdentifier != appToFocus.processIdentifier
    // }
    // reorderedAppList.insert(appToFocus, at: 0)
    // runningApplications = reorderedAppList

    appToFocus.activate(options: [.activateAllWindows])

    // navigateToSecond()
  }

  func switchFocusToSelected() {
    print("switchFocusToSelected, selectedIndex: \(selectedIndex)")
    // guard runningApplications.indices.contains(selectedIndex) else { return }

    switchFocusTo(where: runningApplications[selectedIndex])
    // navigateToSecond()
  }

  func navigateTo(direction: SwitcherNavigationDirection) {
    switch direction {
    case .next:
      selectedIndex += 1
      if selectedIndex >= runningApplications.count - 1 {
        selectedIndex = runningApplications.count - 1
      }

    case .previous:
      selectedIndex -= 1
      if selectedIndex < 0 {
        selectedIndex = 0
      }
    }
  }

  func navigateToFirst() {
    selectedIndex = 0
  }

  func navigateToSecond() {
    guard runningApplications.count > 0 else { return }
    selectedIndex = 1
  }

  @objc private func handleAndleApplicationDidLaunch(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    else {
      return
    }

    if app.activationPolicy == .regular {
      DispatchQueue.main.async {
        self.runningApplications.append(app)
      }
    }
  }

  @objc private func handleAndleApplicationDidTerminate(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    else {
      return
    }

    DispatchQueue.main.async {
      self.runningApplications.removeAll { $0.processIdentifier == app.processIdentifier }
    }
  }

  private func getRunningApplications() {
    runningApplications = NSWorkspace.shared.runningApplications.filter {
      $0.activationPolicy == .regular
    }
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }
}
