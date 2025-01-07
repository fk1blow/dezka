//
//  AppSwitcher.swift
//  Dezka
//

import SwiftUI

protocol AppSwitcherUI: AnyObject {
  var cycleStateMachine: AppSwitcherCycleStateMachine { get }
  func appSwitcherShouldRemainOpen()
  func appSwitcherShouldClose()
}

protocol AppSwitcherNavigation: AnyObject {
  func navigateToNextApp()
  func navigateToPreviousApp()
}

protocol AppSwitcherMonitoringDelegate: AnyObject {
  func didReleaseActivationKey()
  func didActivateAppOnSameSpace(app: NSRunningApplication)
  func willActivateAppOnDifferentSpace(app: NSRunningApplication)
  func didFinishSpaceTransitionFor(app: NSRunningApplication)
}

class AppSwitcher: ObservableObject, AppSwitcherMonitoringDelegate, AppSwitcherNavigation,
  AppSwitcherUI
{
  private let appNavigator = AppNavigator()
  private let activationKeyMonitor = ActivationKeyMonitor()
  private let activationTransitionMonitor = ActivationTransitionMonitor()
  private(set) var cycleStateMachine = AppSwitcherCycleStateMachine()

  init() {
    activationKeyMonitor.delegate = self
    activationTransitionMonitor.delegate = self
  }

  func navigateToNextApp() {
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
      activationKeyMonitor.enableMonitoring()
      appNavigator.navigateToNext()

    // This is a state that might be reached when the app switcher was in the process of activating
    // an app, but an external factor(eg: mouse clicking/holding on another app) caused the switcher
    // to get stuck in the `.shouldActivateApp` state.
    // When the dezka hotkey is being triggered, we assume that the user wants to continue the navigation
    // to the next app, so we can simply resume the navigation from the start.
    case .shouldActivateApp:
      Debug.log("... state in .shouldActivateApp, resume navigation to next app")
      // go into the state of navigating through apps
      cycleStateMachine.continueNavigation()
      // reset the navigation(otherwise we would be stuck on the same app)
      // TODO: calling `resetNavigation` from here is a bit leaky, b/c the switcher knows or assumes
      // about the internals of the navigator
      appNavigator.resetNavigation()
      appNavigator.navigateToNext()
      // enable activation key monitor
      activationKeyMonitor.enableMonitoring()

    case .navigatingThroughApps:
      appNavigator.navigateToNext()

    case .activatedAppOnSameSpace, .transitionToAppOnDifferentSpace, .focusedWhileOpen:
      break
    }
  }

  func navigateToPreviousApp() {
    // TODO: implement this function
    print("navigateToPreviousApp")
  }

  func didReleaseActivationKey() {
    guard cycleStateMachine.state == .navigatingThroughApps else { return }
    // we are now in the state of activating the app
    cycleStateMachine.activateApp()
    // no longer need to monitor the activation key
    activationKeyMonitor.disableMonitoring()
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

    Debug.log("didActivateAppOnSameSpace: \(app.localizedName ?? "unknown")")

    // This happens when the app switcher is in the process of navigating to the next app
    // but an external factor(eg: mouse clicking and holding on an app) causes the app switcher
    // to be stuck in the `.navigatingThroughApps` state.
    // In this case, the switcher assumes that an app has already been activated, therefore nothing
    // else needs to be done but to finish the activation flow.
    if cycleStateMachine.state == .navigatingThroughApps {
      Debug.log("... state in .navigatingThroughApps, finish activation flow")

      cycleStateMachine.finishActivationFlow()
      activationKeyMonitor.disableMonitoring()
      // reset the navigation
      appNavigator.resetNavigation()
      return
    }

    // This could happen if the user clicks on Dezka's content view then releases, which will
    // cause the app switcher to switch to an app on the same space, but somehow got stucked
    // in a state where it thinks it should activate an app on a different space.
    if cycleStateMachine.state == .transitionToAppOnDifferentSpace {
      Debug.log("... state in .transitionToAppOnDifferentSpace, finish activation flow")
      cycleStateMachine.finishActivationFlow()
      return
    }

    // TODO find the edge case where this could happen, then consider describing it in the comment
    if cycleStateMachine.state == .shouldActivateApp {
      Debug.log("... state in .shouldActivateApp, finish activation flow")
      cycleStateMachine.finishActivationFlow()
      return
    }
  }

  func willActivateAppOnDifferentSpace(app: NSRunningApplication) {
    guard cycleStateMachine.state == .shouldActivateApp else { return }

    Debug.log("willActivateAppOnDifferentSpace: \(app.localizedName ?? "unknown")")

    cycleStateMachine.startAppTransition()
  }

  func didFinishSpaceTransitionFor(app: NSRunningApplication) {
    Debug.log("didFinishSpaceTransitionFor: \(app.localizedName ?? "unknown")")

    activationTransitionMonitor.disable()

    cycleStateMachine.finishActivationFlow()
  }

  func appSwitcherShouldRemainOpen() {
    cycleStateMachine.keepAppSwitcherOpen()
  }

  func appSwitcherShouldClose() {
    // no longer need to monitor the activation key
    activationKeyMonitor.disableMonitoring()
    // now we monitor activation, either to an app on the same or a different space
    activationTransitionMonitor.disable()
    // we're no longer interested in any action; deactivate the app switcher
    cycleStateMachine.deactivateAppSwitcher()
  }
}

// TODO: Transform this into to a reducer(should i?)
// Don't like this mess, but it's a start
enum AppSwitcherCycleState {
  // The user is cycling/navigating through the apps but haven't decided to activate one yet
  case navigatingThroughApps
  // The user wants to search/filter through the apps list, so the main ui has focus.
  // This means we don't care about triggering the activation key.
  // It should be able to transition away when the user either:
  // clicks outside the app or the ui(throught the esc key)
  // signals that it wants to close activate or the user has selected an app to activate
  case focusedWhileOpen
  // The user has decided to activate an app, but the app switcher doesn't knnow yet if the
  // app is on the same space or not.
  // This state is used to transition to the next state, which is either `.activatedAppOnSameSpace`
  // or `.transitionToAppOnDifferentSpace`, depending on the app's space.
  case shouldActivateApp
  // The user has decided to activate an app on a different space
  case transitionToAppOnDifferentSpace
  // The user has decided to activate an app on the same space
  case activatedAppOnSameSpace
  // The app switcher is not active, no ui is shown, nothing is being monitored,
  // except for dezka's hotkey(activation key)
  case switcherInactive
}

class AppSwitcherCycleStateMachine: ObservableObject {
  @Published private(set) var state: AppSwitcherCycleState = .switcherInactive {
    didSet {
      Debug.log("new state: \(state)")
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

  func deactivateAppSwitcher() {
    state = .switcherInactive
  }

  func startAppTransition() {
    state = .transitionToAppOnDifferentSpace
  }

  func keepAppSwitcherOpen() {
    state = .focusedWhileOpen
  }
}
