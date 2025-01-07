//
//  MainCoordinator.swift
//  Dezka
//

import KeyboardShortcuts
import SwiftUI

class MainCoordinator {
  private let appSwitcher: AppSwitcher
  private let viewCoordinator: ViewCoordinator
  private var navigationTimer: Timer?
  private var delayTimer: Timer?
  private let selectionInterval: TimeInterval = 0.05  // Adjust this value to control speed
  private let delayInterval: TimeInterval = 0.4
  private let navigationToNext = true

  init() {
    appSwitcher = AppSwitcher()
    viewCoordinator = ViewCoordinator(appSwitcher: self.appSwitcher)
  }

  func handleHotkey() {
    // TODO refactor this
    KeyboardShortcuts.onKeyUp(for: .dezkaHotkeyNext) { [self] in
      navigationTimer?.invalidate()
      navigationTimer = nil

      delayTimer?.invalidate()
      delayTimer = nil
    }

    // TODO refactor this
    KeyboardShortcuts.onKeyDown(for: .dezkaHotkeyNext) { [self] in
      print("--------------- hotkey")
      startDelayTimer()

      viewCoordinator.showSwitcherWindow()
      appSwitcher.navigateToNextApp()
    }
  }

  func startDelayTimer() {
    delayTimer = Timer.scheduledTimer(withTimeInterval: delayInterval, repeats: false) { [self] _ in
      startNavigationTimer()
    }
  }

  func startNavigationTimer() {
    navigationTimer = Timer.scheduledTimer(withTimeInterval: selectionInterval, repeats: true) {
      [weak self] _ in
      if self?.navigationToNext == true {
        self?.appSwitcher.navigateToNextApp()
      } else {
        self?.appSwitcher.navigateToPreviousApp()
      }
    }
  }
}
