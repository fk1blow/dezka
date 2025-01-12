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
  private let navigationInterval: TimeInterval = 0.04
  private let navigationDelay: Double = 0.3
  private var navigationTraversal = AppNavigatorTraversal.next

  init() {
    appSwitcher = AppSwitcher()
    viewCoordinator = ViewCoordinator(appSwitcher: self.appSwitcher)
  }

  func handleHotkey() {
    KeyboardShortcuts.onKeyUp(for: .dezkaHotkeyNext) { [self] in
      stopNavigationTimer()
      stopDelayedTimer()
    }
    KeyboardShortcuts.onKeyDown(for: .dezkaHotkeyNext) { [self] in
      print("--------------- hotkey")

      self.navigationTraversal = .next
      createNavigationDelayTimer()

      viewCoordinator.showSwitcherWindow()
      appSwitcher.navigateToNextApp()
    }

    KeyboardShortcuts.onKeyUp(for: .dezkaHotkeyPrevious) { [self] in
      stopNavigationTimer()
      stopDelayedTimer()
    }
    KeyboardShortcuts.onKeyDown(for: .dezkaHotkeyPrevious) { [self] in
      print("--------------- hotkey")

      self.navigationTraversal = .previous
      createNavigationDelayTimer()

      viewCoordinator.showSwitcherWindow()
      appSwitcher.navigateToPreviousApp()
    }
  }

  private func createNavigationDelayTimer() {
    delayTimer = Timer.scheduledTimer(withTimeInterval: navigationDelay, repeats: false) {
      [self] _ in
      createNavigationRepeatTimer()
    }
  }

  private func stopDelayedTimer() {
    delayTimer?.invalidate()
    delayTimer = nil
  }

  private func createNavigationRepeatTimer() {
    navigationTimer = Timer.scheduledTimer(withTimeInterval: navigationInterval, repeats: true) {
      [weak self] _ in
      if self?.navigationTraversal == .next {
        self?.appSwitcher.navigateToNextApp()
      } else {
        self?.appSwitcher.navigateToPreviousApp()
      }
    }
  }

  private func stopNavigationTimer() {
    navigationTimer?.invalidate()
    navigationTimer = nil
  }
}
