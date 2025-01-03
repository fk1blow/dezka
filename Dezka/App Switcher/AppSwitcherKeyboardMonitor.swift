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
  func keyboardMonitorDidCompleteActivation()
  func keyboardMonitorDidTriggerNavigation(to direction: SwitcherNavigationDirection)
}

// alternative names: AppSwitcherActivationMonitor, AppSwitcherKeyboardMonitor, AppSwitcherKeyboardHandler,
class AppSwitcherKeyboardMonitor {
  weak var delegate: AppSwitcherKeyboardMonitorDelegate?

  private var flagsChangedEventMonitor: Any?
  private var activeModifierKeys: Set<ModifierKey> = []

  func startMonitoring() {
    activeModifierKeys = [
      ModifierKey.shift,
      ModifierKey.option,
      ModifierKey.control,
    ]

    flagsChangedEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
      self.handleKeyModifierEvent(event: event)
    }

    // keyPressedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) {
    //   event in
    //   self.handleKeyCharsEvent(event: event)
    //   return event
    // }
  }

  func stopMonitoring() {
    if let monitor = flagsChangedEventMonitor {
      print("remove flagsChangedEventMonitor")
      NSEvent.removeMonitor(monitor)
      flagsChangedEventMonitor = nil
    }

    // if let monitor = keyPressedEventMonitor {
    //   NSEvent.removeMonitor(monitor)
    //   keyPressedEventMonitor = nil
    // }
  }

  private func handleKeyModifierEvent(event: NSEvent) {
    // print("handleKeyModifierEvent: \(event.keyCode)")

    // guard monitoringIsActive else { return }

    if let foundKey = ModifierKey.fromKeyCode(event.keyCode) {
      activeModifierKeys.remove(foundKey)
    }

    if activeModifierKeys.isEmpty, delegate != nil {
      stopMonitoring()
      delegate?.keyboardMonitorDidCompleteActivation()
    }
  }

  private func handleKeyCharsEvent(event: NSEvent) {
    // guard monitoringIsActive else { return }

    // print("handleKeyCharsEvent: \(event.keyCode)")

    // guard activeModifierKeys.containsCombination([.shift, .control, .option]) else { return }

    if event.type == .keyDown {
      // "11" is the key code for "b" key
      if event.keyCode == 11 {
        delegate?.keyboardMonitorDidTriggerNavigation(to: .next)
        // "9" is the key code for "v" key
      } else if event.keyCode == 9 {
        delegate?.keyboardMonitorDidTriggerNavigation(to: .previous)
      }
    }
  }
}
