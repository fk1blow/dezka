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
  private let cycleStateMachine = AppSwitcherCycleStateMachine()

  init() {
    activationKeyMonitor.delegate = self
    activationTransitionMonitor.delegate = self
  }

  func switchToNextApp() {
    // If the state is .activating, this means another factor(eg: mouse cliking on an app)
    // prevented the app switcher from finishing the activation.
    // This causes the app switcher to be stuck in the '.activating' state and unable to switch
    // to the next app, until some other event triggers the app switcher to move to the next state.
    if cycleStateMachine.state == .activating {
      // notsure if this is the right way to handle this
      // but for now...
      activationKeyMonitor.disable()

      activationTransitionMonitor.enable()
      activationKeyMonitor.enable()

      // want to start from the beginning
      // and continue just like it would in the `.inactive` state
      appNavigator.resetNavigation()
      appNavigator.navigateToNext()

      cycleStateMachine.goToCyclingState()

      return
    }

    guard cycleStateMachine.state == .inactive || cycleStateMachine.state == .cycling else {
      return
    }

    switch cycleStateMachine.state {
    case .inactive:
      activationTransitionMonitor.enable()
      activationKeyMonitor.enable()
      appNavigator.navigateToNext()
      cycleStateMachine.next()
    case .cycling:
      appNavigator.navigateToNext()
    case .activating:
      break
    }
  }

  func didReleaseActivationKey() {
    guard cycleStateMachine.state == .cycling else { return }

    appNavigator.activateSelectedApp()

    // disable all monitors
    activationTransitionMonitor.disable()
    activationKeyMonitor.disable()

    // this should implicitly go to the `.activating` state
    cycleStateMachine.next()
  }

  func didActivateAppOnSameSpace(app: NSRunningApplication) {
    // This happens when the app switcher is in the process of navigating to the next app
    // but an external factor(eg: mouse clicking and holding on an app) causes the app switcher
    // to be stuck in the `.activating` state.
    // In this case, the app switcher can simply assume that the app has been activated
    // and move to the inactive state.
    if cycleStateMachine.state == .cycling {
      cycleStateMachine.goToInactiveState()
      // disable every monitor
      activationTransitionMonitor.disable()
      activationKeyMonitor.disable()
      // reset the navigation
      appNavigator.resetNavigation()
      return
    }

    guard cycleStateMachine.state == .activating else { return }

    cycleStateMachine.next()
  }

  func didFinishSpaceTransitionFor(app: NSRunningApplication) {
    guard cycleStateMachine.state == .activating else { return }

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
      // print("# new state: \(state)")
    }
  }

  func goToCyclingState() {
    state = .cycling
  }

  func goToInactiveState() {
    state = .inactive
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
