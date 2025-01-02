//
//  AppSwitcher.swift
//  Dezka
//

protocol AppSwitcherDelegate: AnyObject {
  func appSwitcherDidFinish()
}

class AppSwitcher: AppSwitcherKeyboardMonitorDelegate {
  weak var delegate: AppSwitcherDelegate?

  private let keyboardMonitor = AppSwitcherKeyboardMonitor()
  private let appSwitcherNavigator = AppSwitcherNavigator()

  init() {
    keyboardMonitor.delegate = self
  }

  func enable() {
    print("AppSwitcher enable")
    keyboardMonitor.startMonitoring()
    appSwitcherNavigator.navigateToNext()
  }

  func disable() {
    print("AppSwitcher disable")
    keyboardMonitor.stopMonitoring()
  }

  func didCompleteActivation() {
    print("didComplateActivation")
    if let selectedApp = appSwitcherNavigator.getSelectedApp() {
      selectedApp.activate(options: [.activateAllWindows])
    }
    appSwitcherNavigator.navigateToFirst()
    delegate?.appSwitcherDidFinish()
  }

  func didTriggerNavigation(to direction: SwitcherNavigationDirection) {
    print("didTriggerNavigation: \(direction)")
    switch direction {
    case .next:
      appSwitcherNavigator.navigateToNext()
    case .previous:
      appSwitcherNavigator.navigaToPrevious()
    }
  }
}
