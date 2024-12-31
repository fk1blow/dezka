//
//  CmdTabEventHandler.swift
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

protocol SwitcherActivationMonitorDelegate: AnyObject {
  func switcherActivationDidEnd()
  func switcherNavigationDidTrigger(to direction: SwitcherNavigationDirection)
}

class SwitcherActivationMonitor {
  weak var delegate: SwitcherActivationMonitorDelegate?

  private var flagsChangedEventMonitor: Any?
  private var keyPressedEventMonitor: Any?
  private var activeModifierKeys: Set<ModifierKey> = []

  func startMonitor() {
    print("startMonitoru")

    activeModifierKeys = [
      ModifierKey.shift,
      ModifierKey.option,
      ModifierKey.control,
    ]

    flagsChangedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
      self.handleKeyModifierEvent(event: event)
      return event
    }

    keyPressedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) {
      event in
      self.handleKeyCharsEvent(event: event)
      return event
    }
  }

  func stopMonitor() {
    if let monitor = flagsChangedEventMonitor {
      NSEvent.removeMonitor(monitor)
      flagsChangedEventMonitor = nil
    }

    if let monitor = keyPressedEventMonitor {
      NSEvent.removeMonitor(monitor)
      keyPressedEventMonitor = nil
    }
  }

  private func handleKeyModifierEvent(event: NSEvent) {
    if let foundKey = ModifierKey.fromKeyCode(event.keyCode) {
      activeModifierKeys.remove(foundKey)
    }

    if activeModifierKeys.isEmpty, delegate != nil {
      delegate?.switcherActivationDidEnd()
    }
  }

  private func handleKeyCharsEvent(event: NSEvent) {
    guard activeModifierKeys.containsCombination([.shift, .control, .option]) else { return }

    if event.type == .keyDown {
      // "5" is the key code for "g" key
      if event.keyCode == 5 {
        delegate?.switcherNavigationDidTrigger(to: .next)
        // "17" is the key code for "t" key
      } else if event.keyCode == 17 {
        delegate?.switcherNavigationDidTrigger(to: .previous)
      }
    }
  }
}
