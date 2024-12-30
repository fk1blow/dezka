//
//  AppDelegate.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject {
  @Published var runningAppsMonitor = RunningAppsMonitor()

  private var statusItem: NSStatusItem!
  private var window: NSWindow?

  private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

  override init() {
    super.init()
    if isPreview {
      // fetchRunningApps()
    }
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if !isPreview {
      createMenu()
    }

    KeyboardShortcuts.onKeyDown(for: .dezkaHotkey) { [self] in
      createWindow()
    }
  }

  func windowDidResignKey(_ notification: Notification) {
    window?.close()
    window = nil
    // This causes all the windows(belonging to this app) to be hidden
    // NSApp.hide(nil)
  }

  private func createWindow() {
    if window == nil {
      let contentView = ContentView().environmentObject(self)

      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 550, height: 450),
        styleMask: [.titled, .fullSizeContentView],
        backing: .buffered, defer: false
      )
      window?.delegate = self
      window?.isReleasedWhenClosed = false
      window?.contentView = NSHostingView(rootView: contentView.frame(width: 550, height: 450))
      window?.titleVisibility = .hidden
      window?.titlebarAppearsTransparent = true
      window?.isMovable = false
      window?.center()
    }

    NSApp.activate(ignoringOtherApps: true)
    window?.makeKeyAndOrderFront(nil)
    window?.orderFrontRegardless()
  }

  private func createMenu() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "circle.circle", accessibilityDescription: "Menu Icon"
      )
    }

    let menu = NSMenu()
    menu.addItem(
      NSMenuItem(title: "Quit", action: #selector(handleMenuQuitApp), keyEquivalent: "q"))
    statusItem.menu = menu
  }

  @objc private func handleMenuQuitApp() {
    NSApplication.shared.terminate(self)
  }
}
