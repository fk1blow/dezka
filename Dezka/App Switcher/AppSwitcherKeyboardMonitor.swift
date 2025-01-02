//
//  AppSwitcherKeyboardMonitor.swift
//  Dezka
//

import SwiftUI

extension Set where Element == ModifierKey {
  func containsCombination(_ keys: [ModifierKey]) -> Bool {
    return keys.allSatisfy { self.contains($0) }
  }
}

enum ModifierKey: UInt16 {
  case shift = 56
  case option = 58
  case control = 59

  static func fromKeyCode(_ keyCode: UInt16) -> ModifierKey? {
    return ModifierKey(rawValue: keyCode)
  }
}

enum SwitcherNavigationDirection {
  case next
  case previous
}

protocol AppSwitcherKeyboardMonitorDelegate: AnyObject {
  func didCompleteActivation()
  func didTriggerNavigation(to direction: SwitcherNavigationDirection)
}

// alternative names: AppSwitcherActivationMonitor, AppSwitcherKeyboardMonitor, AppSwitcherKeyboardHandler,
class AppSwitcherKeyboardMonitor {
  weak var delegate: AppSwitcherKeyboardMonitorDelegate?

  private var flagsChangedEventMonitor: Any?
  private var keyPressedEventMonitor: Any?
  private var activeModifierKeys: Set<ModifierKey> = []

  private var monitoringIsActive = false

  init() {
    // TODO: remove monitors on deinit
    flagsChangedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
      self.handleKeyModifierEvent(event: event)
      return event
    }

    // TODO: remove monitors on deinit
    // keyPressedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) {
    keyPressedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) {
      event in
      self.handleKeyCharsEvent(event: event)
      return event
    }
  }

  func startMonitoring() {
    print("startMonitoring")

    monitoringIsActive = true

    activeModifierKeys = [
      ModifierKey.shift,
      ModifierKey.option,
      ModifierKey.control,
    ]
  }

  func stopMonitoring() {
    print("stopMonitoring")

    monitoringIsActive = false

    // if let monitor = flagsChangedEventMonitor {
    //   NSEvent.removeMonitor(monitor)
    //   flagsChangedEventMonitor = nil
    // }

    // if let monitor = keyPressedEventMonitor {
    //   NSEvent.removeMonitor(monitor)
    //   keyPressedEventMonitor = nil
    // }
  }

  private func handleKeyModifierEvent(event: NSEvent) {
    print("handleKeyModifierEvent: \(event.type), \(event.keyCode)")

    guard monitoringIsActive else { return }

    if let foundKey = ModifierKey.fromKeyCode(event.keyCode) {
      activeModifierKeys.remove(foundKey)
    }

    if activeModifierKeys.isEmpty, delegate != nil {
      delegate?.didCompleteActivation()
    }
  }

  private func handleKeyCharsEvent(event: NSEvent) {
    print("handleKeyCharsEvent: \(event.keyCode)")

    guard monitoringIsActive else { return }

    guard activeModifierKeys.containsCombination([.shift, .control, .option]) else { return }

    if event.type == .keyDown {
      // "11" is the key code for "b" key
      if event.keyCode == 11 {
        delegate?.didTriggerNavigation(to: .next)
        // "9" is the key code for "v" key
      } else if event.keyCode == 9 {
        delegate?.didTriggerNavigation(to: .previous)
      }
    }
  }
}
