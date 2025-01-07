//
//  AppSwitcher.swift
//  Dezka
//

import Combine
import SwiftUI

protocol AppSwitcherUI: AnyObject {
  var cycleState: AppSwitcherCycleStateMachine { get }
  func appSwitcherShouldRemainOpen()
  func appSwitcherShouldClose()
}

protocol AppSwitcherNavigation: AnyObject {
  var navigationState: AnyPublisher<AppNavigatorState, Never> { get }
  func navigateToNextApp()
  func navigateToPreviousApp()
  func activateSelectedApp()
}

protocol AppSwitcherMonitoringDelegate: AnyObject {
  func didReleaseActivationKey()
  func didActivateAppOnSameSpace(app: NSRunningApplication)
  func willActivateAppOnDifferentSpace(app: NSRunningApplication)
  func didFinishSpaceTransitionFor(app: NSRunningApplication)
}

class AppSwitcher: ObservableObject, AppSwitcherMonitoringDelegate {
  let cycleStateMachine = AppSwitcherCycleStateMachine()
  let appNavigator = AppNavigator()
  private let activationKeyMonitor = ActivationKeyMonitor()
  private let activationTransitionMonitor = ActivationTransitionMonitor()

  init() {
    activationKeyMonitor.delegate = self
    activationTransitionMonitor.delegate = self
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

    // TODO: find the edge case where this could happen, then consider describing it in the comment
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
}

extension AppSwitcher: AppSwitcherNavigation {
  var navigationState: AnyPublisher<AppNavigatorState, Never> {
    appNavigator.$state.eraseToAnyPublisher()
  }

  func navigateToNextApp() {
    handleNavigationTraversal(in: .next)
  }

  func navigateToPreviousApp() {
    handleNavigationTraversal(in: .previous)
  }

  func activateSelectedApp() {
    appNavigator.activateSelectedApp()
  }

  private func handleNavigationTraversal(in traversal: AppNavigatorTraversal) {
    let navigatorTraversalFn =
      traversal == .next ? appNavigator.navigateToNext : appNavigator.navigateToPrevious

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
      navigatorTraversalFn()

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
      navigatorTraversalFn()
      // enable activation key monitor
      activationKeyMonitor.enableMonitoring()

    case .navigatingThroughApps:
      navigatorTraversalFn()

    case .activatedAppOnSameSpace, .transitionToAppOnDifferentSpace, .focusedWhileOpen:
      break
    }
  }
}

extension AppSwitcher: AppSwitcherUI {
  var cycleState: AppSwitcherCycleStateMachine {
    cycleStateMachine
  }

  func appSwitcherShouldRemainOpen() {
    cycleStateMachine.keepAppSwitcherOpen()
  }

  func appSwitcherShouldClose() {
    // reset the navigation
    appNavigator.resetNavigation()
    // no longer need to monitor the activation key
    activationKeyMonitor.disableMonitoring()
    // now we monitor activation, either to an app on the same or a different space
    activationTransitionMonitor.disable()
    // we're no longer interested in any action; deactivate the app switcher
    cycleStateMachine.deactivateAppSwitcher()
  }
}
