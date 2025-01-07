//
//  MainCoordinator.swift
//  Dezka
//

import KeyboardShortcuts
import SwiftUI

class MainCoordinator {
  private let appSwitcher: AppSwitcher
  private let viewCoordinator: ViewCoordinator

  init() {
    appSwitcher = AppSwitcher()
    viewCoordinator = ViewCoordinator(appSwitcher: self.appSwitcher)
  }

  func handleHotkey() {
    KeyboardShortcuts.onKeyDown(for: .dezkaHotkey) { [self] in
      print("--------------- hotkey")

      viewCoordinator.showSwitcherWindow()
      appSwitcher.navigateToNextApp()
    }
  }
}
