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
    guard
      cycleStateMachine.state == .switcherInactive
        || cycleStateMachine.state == .navigatingThroughApps
        || cycleStateMachine.state == .shouldActivateApp
        || cycleStateMachine.state == .switcherInactive
    else { return }

    switch cycleStateMachine.state {
    case .switcherInactive:
      cycleStateMachine.continueNavigation()
      // activationTransitionMonitor.enable()
      activationKeyMonitor.enable()
      appNavigator.navigateToNext()

      break

    // This is a state that might be reached when the app switcher was in the process of activating
    // an app, but an external factor(eg: mouse clicking/holding on another app) caused the switcher
    // to get stuck in the `.shouldActivateApp` state.
    // When the dezka hotkey is being triggered, we assume that the user wants to continue the navigation
    // to the next app, so we can simply resume the navigation from the start.
    case .shouldActivateApp:
      // print("... state in .shouldActivateApp, resume navigation to next app")
      // go into the state of navigating through apps
      cycleStateMachine.continueNavigation()
      // reset the navigation(otherwise we would be stuck on the same app)
      // TODO calling `resetNavigation` from here is a bit leaky, b/c the switcher knows or assumes
      // about the internals of the navigator
      appNavigator.resetNavigation()
      appNavigator.navigateToNext()
      // enable activation key monitor
      activationKeyMonitor.enable()

      break

    case .navigatingThroughApps:
      appNavigator.navigateToNext()
      break

    case .activatedAppOnSameSpace, .transitionToAppOnDifferentSpace:
      break
    }
  }

  func didReleaseActivationKey() {
    guard cycleStateMachine.state == .navigatingThroughApps else { return }
    // we are now in the state of activating the app
    cycleStateMachine.activateApp()
    // no longer need to monitor the activation key
    activationKeyMonitor.disable()
    // now we monitor activation, either to an app on the same or a different space
    activationTransitionMonitor.enable()
    // and finally we activate the selected apop
    appNavigator.activateSelectedApp()
  }

  func didActivateAppOnSameSpace(app: NSRunningApplication) {
    // no longer need to monitor the activation transition
    activationTransitionMonitor.disable()

    // we're interested in any action while the switcher is not inactive
    guard cycleStateMachine.state != .switcherInactive else { return }

    print("didActivateAppOnSameSpace: \(app.localizedName)")

    // This happens when the app switcher is in the process of navigating to the next app
    // but an external factor(eg: mouse clicking and holding on an app) causes the app switcher
    // to be stuck in the `.navigatingThroughApps` state.
    // In this case, the switcher assumes that an app has already been activated, therefore nothing
    // else needs to be done but to finish the activation flow.
    if cycleStateMachine.state == .navigatingThroughApps {
      print("... state in .navigatingThroughApps, finish activation flow")

      cycleStateMachine.finishActivationFlow()
      activationKeyMonitor.disable()
      // reset the navigation
      // TODO calling `resetNavigation` from here is a bit leaky, b/c the switcher knows or assumes
      // about the internals of the navigator
      appNavigator.resetNavigation()
      return
    }

    if cycleStateMachine.state == .shouldActivateApp {
      cycleStateMachine.finishActivationFlow()
      return
    }
  }

  func willActivateAppOnDifferentSpace(app: NSRunningApplication) {
    guard cycleStateMachine.state == .shouldActivateApp else { return }

    print("willActivateAppOnDifferentSpace: \(app.localizedName)")

    cycleStateMachine.startAppTransition()
  }

  func didFinishSpaceTransitionFor(app: NSRunningApplication) {
    print("didFinishSpaceTransitionFor: \(app.localizedName)")

    activationTransitionMonitor.disable()

    cycleStateMachine.finishActivationFlow()
  }

}

enum AppSwitcherCycleState {
  case navigatingThroughApps
  case shouldActivateApp
  case transitionToAppOnDifferentSpace
  case activatedAppOnSameSpace
  case switcherInactive
}

class AppSwitcherCycleStateMachine {
  private(set) var state: AppSwitcherCycleState = .switcherInactive {
    didSet {
      print("*** new state: \(state) ***")
      if state == .switcherInactive {
        print("--------------- final state")
      }
    }
  }

  func activateApp() {
    state = .shouldActivateApp
  }

  func continueNavigation() {
    state = .navigatingThroughApps
  }

  func finishActivationFlow() {
    state = .switcherInactive
  }

  func startAppTransition() {
    state = .transitionToAppOnDifferentSpace
  }
}
