//
//  ActivationKeyMonitor.swift
//  Dezka
//

import SwiftUI

protocol ActivationKeyMonitorDelegate: AnyObject {
  func didReleaseActivationKey()
}

class ActivationKeyMonitor {
  weak var delegate: ActivationKeyMonitorDelegate?

  private var flagsChangedEventMonitor: Any?
  private var activeModifierKeys: Set<ModifierKey> = []

  func enable() {
    activeModifierKeys = [
      ModifierKey.shift,
      ModifierKey.option,
      ModifierKey.control,
    ]

    flagsChangedEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { event in
      self.handleKeyModifierEvent(event: event)
    }
  }

  // TODO: this could be managed by the `AppSwitcher` class itself
  func disable() {
    if let monitor = flagsChangedEventMonitor {
      NSEvent.removeMonitor(monitor)
      flagsChangedEventMonitor = nil
    }
  }

  private func handleKeyModifierEvent(event: NSEvent) {
    // TODO: handle partial key modifiers(eg: only `alt+ctrl` instead of `shift+alt+ctrl`),
    // which should test against a copy of the `activeModifierKeys` set
    if let foundKey = ModifierKey.fromKeyCode(event.keyCode) {
      activeModifierKeys.remove(foundKey)
    }

    if activeModifierKeys.isEmpty, delegate != nil {
      disable()
      delegate?.didReleaseActivationKey()
    }
  }
}

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
