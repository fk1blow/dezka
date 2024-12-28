//
//  Notifications+Name.swift
//  dezka
//

import Foundation

extension Notification.Name {
  // global stuff(might break it down into more granular commands)
  static let appSearchClear = Notification.Name("AppSearchClear")

  // hide the app
  static let applicationShouldHide = Notification.Name("ApplicationShouldHide")
  static let applicationWillHide = Notification.Name("ApplicationWillHide")

  // user selected/clicked an app from the apps item list
  static let appListItemSelect = Notification.Name("AppListItemSelect")

  // navigate througn the apps list
  static let appListNavigateUp = Notification.Name("AppListNavigateUp")
  static let appListNavigateDown = Notification.Name("AppListNavigateDown")
  
  // toggling between switcher and search modes
  static let appModeChangeToSearchMode = Notification.Name("AppModeChangeToSearchMode")
  static let appModeChangeToSwitchMode = Notification.Name("AppModeChangeToSwitchMode")
}
