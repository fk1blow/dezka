//
//  ActivationKeyMonitor.swift
//  Dezka
//

import AppKit

class ActivationKeyMonitor {
  weak var delegate: AppSwitcherMonitoringDelegate?

  private var monitoringIsActive = false {
    willSet {
      if newValue {
        activeModifierKeys = [
          ModifierKey.shift,
          ModifierKey.option,
          ModifierKey.control,
        ]
      }
    }
  }
  private var flagsChangedEventMonitor: Any?
  private var activeModifierKeys: Set<ModifierKey> = []
  private var isAppActive: Bool { NSApp.isActive }

  init() {
    // Observe Dezka app focus changes to switch monitors dynamically
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: NSApplication.didBecomeActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidResignActive),
      name: NSApplication.didResignActiveNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    disableMonitoring()
  }

  func enableMonitoring() {
    monitoringIsActive = true
    addAppropriateEventMonitor()
  }

  func disableMonitoring() {
    monitoringIsActive = false
    removeEventMonitor()
  }

  private func addAppropriateEventMonitor() {
    removeEventMonitor()  // Ensure no duplicate monitors

    // don't want to monitor either types of events
    guard monitoringIsActive == true else { return }

    if isAppActive {
      addLocalEventMonitor()
    } else {
      addGlobalEventMonitor()
    }
  }

  private func addGlobalEventMonitor() {
    flagsChangedEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) {
      [weak self] event in
      self?.handleKeyModifierEvent(event: event)
    }
  }

  private func addLocalEventMonitor() {
    flagsChangedEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
      [weak self] event in
      self?.handleKeyModifierEvent(event: event)
      return event  // Allow event propagation
    }
  }

  private func removeEventMonitor() {
    if let monitor = flagsChangedEventMonitor {
      NSEvent.removeMonitor(monitor)
      flagsChangedEventMonitor = nil
    }
  }

  private func handleKeyModifierEvent(event: NSEvent) {
    if let foundKey = ModifierKey.fromKeyCode(event.keyCode) {
      activeModifierKeys.remove(foundKey)
    }

    if activeModifierKeys.isEmpty {
      disableMonitoring()
      delegate?.didReleaseActivationKey()
    }
  }

  @objc private func appDidBecomeActive() {
    addAppropriateEventMonitor()
  }

  @objc private func appDidResignActive() {
    addAppropriateEventMonitor()
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
