//
//  AppSwitcher.swift
//  Dezka
//

import SwiftUI

protocol AppSwitcherDelegate: AnyObject {
  func appSwitcherDidFinish()
}

class AppSwitcher: AppSwitcherKeyboardMonitorDelegate, AppSwitcherNavigatorDelegate {
  weak var delegate: AppSwitcherDelegate?

  private let keyboardMonitor = AppSwitcherKeyboardMonitor()
  private let appNavigator = AppSwitcherNavigator()

  private var cycleStateMachine = AppSwitcherCycleStateMachine()

  init() {
    keyboardMonitor.delegate = self
    appNavigator.delegate = self
  }

  func switchToNextApp() {
    guard cycleStateMachine.state == .inactive || cycleStateMachine.state == .cycling else {
      return
    }

    switch cycleStateMachine.state {
    case .inactive:
      // print("inactive --->")
      keyboardMonitor.startMonitoring()
      appNavigator.navigateToNext()
      cycleStateMachine.next()
    case .cycling:
      // print("cycling --->")
      appNavigator.navigateToNext()
    case .activating:
      // print("waiting --->")
      keyboardMonitor.stopMonitoring()
      // appNavigator.getSelectedApp()?.activate(options: [.activateAllWindows])
      // cycleStateMachine.next()
    }
  }

  func keyboardMonitorDidCompleteActivation() {
    keyboardMonitor.stopMonitoring()

    guard cycleStateMachine.state == .cycling else { return }

    // print("didComplateActivation")

    cycleStateMachine.next()
    appNavigator.activateSelectedApp()
  }

  func keyboardMonitorDidTriggerNavigation(to direction: SwitcherNavigationDirection) {
    print("didTriggerNavigation: \(direction)")
  }

  func navigatorDidActivateSelectedApp(app _: NSRunningApplication) {
    guard cycleStateMachine.state == .activating else { return }

    keyboardMonitor.stopMonitoring()

    print("????")

    // print("navigatorDidActivateSelectedApp: \(app.localizedName ?? "Unknown App")")
    cycleStateMachine.next()
    // app.activate(options: [.activateAllWindows])
    // delegate?.appSwitcherDidFinish()
  }
}

enum AppSwitcherCycleState {
  case inactive
  case cycling
  case activating
}

class AppSwitcherCycleStateMachine {
  private(set) var state: AppSwitcherCycleState = .inactive {
    didSet {
      print("--> state: \(state)")
    }
  }

  init() {
    print("initial state: \(state)")
  }

  func next() {
    switch state {
    case .inactive:
      state = .cycling
    case .cycling:
      state = .activating
    case .activating:
      state = .inactive
    }
  }
}
