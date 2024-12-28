//
//  AppDelegate.swift
//  dezka
//

import Foundation
import HotKey
import SwiftUI

enum AppWorkingMode {
  case switching
  case searching
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
  var statusItem: NSStatusItem!
  var appHotkey: HotKey?
  var window: NSWindow?

  @Published var applicationActive = false
  @Published var runningApps: [NSRunningApplication] = []

  let notificationCenter = NotificationCenter.default
  let workingMode = AppWorkingMode.switching

  func applicationDidFinishLaunching(_ notification: Notification) {
    fetchRunningApps()

    // Create the status bar item
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "circle.circle", accessibilityDescription: "Menu Icon"
      )
    }

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
//    TODO: add preferences menu and window
//    menu.addItem(NSMenuItem(title: "Preferences", action: #selector(nil), keyEquivalent: ","))
    statusItem.menu = menu

    // Set up the global hotkey
    appHotkey = HotKey(key: .r, modifiers: [.shift, .control, .option, .command])
    appHotkey?.keyDownHandler = {
      self.applicationActive = true
      self.buildApplicationWindow()
    }

    notificationCenter.addObserver(
      self,
      selector: #selector(handleApplicationShouldHide),
      name: .applicationShouldHide,
      object: nil
    )
  }

  func applicationDidResignActive(_ notification: Notification) {
    NotificationCenter.default.post(name: .applicationWillHide, object: self)
    window?.close()
    NSApp.hide(nil)
    applicationActive = false
    window = nil
  }

  func applicationWillBecomeActive(_ notification: Notification) {
    fetchRunningApps()
  }

  @objc private func handleApplicationShouldHide() {
    NotificationCenter.default.post(name: .applicationWillHide, object: self)
    window?.close()
    NSApp.hide(nil)
  }

  @objc func quitApp() {
    NSApplication.shared.terminate(self)
  }

  private func buildApplicationWindow() {
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

  private func fetchRunningApps() {
    runningApps = NSWorkspace.shared.runningApplications.filter { app in
      // Include apps with a user interface (and exclude background apps)
      app.activationPolicy == .regular
    }
  }
}
