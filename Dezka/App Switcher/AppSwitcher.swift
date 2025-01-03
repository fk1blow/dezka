//
//  AppSwitcher.swift
//  Dezka
//

import SwiftUI

protocol AppSwitcherDelegate: AnyObject {
  func appSwitcherDidFinish()
}

class AppSwitcher: ActivationKeyMonitorDelegate, ActivationTransitionMonitorDelegate {
  weak var delegate: AppSwitcherDelegate?

  private let activationKeyMonitor = ActivationKeyMonitor()
  private let appNavigator = AppNavigator()
  private let activationTransitionMonitor = ActivationTransitionMonitor()

  private var cycleStateMachine = AppSwitcherCycleStateMachine()

  private var selectedApp: NSRunningApplication?

  init() {
    activationKeyMonitor.delegate = self
    activationTransitionMonitor.delegate = self
  }

  func switchToNextApp() {
    guard cycleStateMachine.state == .inactive || cycleStateMachine.state == .cycling else {
      return
    }

    switch cycleStateMachine.state {
    case .inactive:
      print("inactive --->")

      activationTransitionMonitor.enable()
      activationKeyMonitor.enable()
      appNavigator.navigateToNext()
      cycleStateMachine.next()
    case .cycling:
      print("cycling --->")
      appNavigator.navigateToNext()
    case .activating:
      print("waiting --->")
    // keyboardMonitor.stopMonitoring()
    // appNavigator.getSelectedApp()?.activate(options: [.activateAllWindows])
    // cycleStateMachine.next()
    }
  }

  func didReleaseActivationKey() {
    guard cycleStateMachine.state == .cycling else { return }

    print("didReleaseActivationKey")

    appNavigator.activateSelectedApp()

    activationTransitionMonitor.disable()

    activationKeyMonitor.disable()

    cycleStateMachine.next()
  }

  func didActivateAppOnSameSpace(app: NSRunningApplication) {
    // guard cycleStateMachine.state == .activating else { return }

    // if cycleStateMachine.state == .cycling {

    // }

    print("didActivateAppOnSameSpace: \(app.localizedName ?? "Unknown App")")

    guard cycleStateMachine.state == .activating else { return }

    cycleStateMachine.next()
  }

  func didFinishSpaceTransitionFor(app: NSRunningApplication) {
    guard cycleStateMachine.state == .activating else { return }

    print("didFinishSpaceTransitionFor: \(app.localizedName ?? "Unknown App")")

    cycleStateMachine.next()
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
      print("# new state: \(state)")
    }
  }

  init() {
    print("# initial state: \(state)")
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
