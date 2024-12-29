//
//  Dezka.swift
//  dezka
//

import Foundation
import HotKey
import SwiftUI

enum AppWorkingMode {
  case switching
  case searching
}

class Dezka: ObservableObject {
  var appHotkey: HotKey?
  var window: NSWindow?

  @Published var applicationActive = false
  @Published var runningApps: [NSRunningApplication] = []

  let notificationCenter = NotificationCenter.default
  let workingMode = AppWorkingMode.switching

  func launchApplication() {
    setupKeyboardShortcuts()
    addNotificationObservers()
  }

  func fetchRunningApps() {
    runningApps = NSWorkspace.shared.runningApplications.filter { app in
      // Include apps with a user interface (and exclude background apps)
      app.activationPolicy == .regular
    }
  }

  func deactivateApplication() {
    NotificationCenter.default.post(name: .applicationWillHide, object: self)
    window?.close()
    NSApp.hide(nil)
    applicationActive = false
    window = nil
  }

  private func setupKeyboardShortcuts() {
    appHotkey = HotKey(key: .r, modifiers: [.shift, .control, .option, .command])
    appHotkey?.keyDownHandler = {
      if self.applicationActive == false {
        self.launchApplicationWindow()
        self.applicationActive = true
      }
    }
  }

  private func addNotificationObservers() {
    notificationCenter.addObserver(
      self,
      selector: #selector(handleApplicationShouldHide),
      name: .applicationShouldHide,
      object: nil
    )
  }

  private func launchApplicationWindow() {
    if window == nil {
      let contentView = ContentView().environmentObject(self)
      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 550, height: 450),
        styleMask: [.titled, .closable],
        backing: .buffered, defer: false
      )

      window?.isReleasedWhenClosed = false

      window?.styleMask.remove(.titled)
      window?.styleMask = [.titled, .fullSizeContentView]
      window?.contentView = NSHostingView(rootView: contentView.frame(width: 550, height: 450))
      window?.titleVisibility = .hidden
      window?.titlebarAppearsTransparent = true
      window?.isMovable = false

      window?.center()
    }

    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc private func handleApplicationShouldHide() {
    window?.close()
    NSApp.hide(nil)
  }
}
