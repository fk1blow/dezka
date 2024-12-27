//
//  Notifications+Name.swift
//  cazhan
//

import Foundation

extension Notification.Name {
  // global stuff(might break it down into more granular commands)
  static let escapeKeyPressed = Notification.Name("EscapeKeyPressed")
  // hide the Cazhan app
  static let applicationShouldHide = Notification.Name("ApplicationShouldHide")
  // user selected/clicked an app from the apps item list
  static let appListItemSelect = Notification.Name("AppListItemSelect")
  // navigate througn the apps list
  static let appListNavigateUp = Notification.Name("AppListNavigateUp")
  static let appListNavigateDown = Notification.Name("AppListNavigateDown")
}
