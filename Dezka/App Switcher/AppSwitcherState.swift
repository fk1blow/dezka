//
//  AppSwitcherState.swift
//  Dezka
//

import Combine

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
