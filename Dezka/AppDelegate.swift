//
//  AppDelegate.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject,
  SwitcherActivationMonitorDelegate
{
  @Published var runningAppsMonitor = RunningAppsMonitor()

  private var statusItem: NSStatusItem!
  private var window: NSWindow?

  private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  private let switcherActivationMonitor = SwitcherActivationMonitor()

  override init() {
    super.init()
    switcherActivationMonitor.delegate = self
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if !isPreview {
      createMenu()
    }

    KeyboardShortcuts.onKeyDown(for: .dezkaHotkey) { [self] in
      print("Hotkey pressed")
      createWindow()
      KeyboardShortcuts.disable(.dezkaHotkey)
      switcherActivationMonitor.startMonitor()
    }
  }

  func windowDidResignKey(_ notification: Notification) {
    hideApp()
    KeyboardShortcuts.enable(.dezkaHotkey)
    switcherActivationMonitor.stopMonitor()
  }

  func switcherActivationDidEnd() {
    hideApp()
    NotificationCenter.default.post(name: .appListItemSelect, object: nil)
    KeyboardShortcuts.enable(.dezkaHotkey)
    switcherActivationMonitor.stopMonitor()
  }

  func switcherNavigationDidTrigger(to direction: SwitcherNavigationDirection) {
    switch direction {
    case .next:
      NotificationCenter.default.post(name: .appListNavigateDown, object: nil)
    case .previous:
      NotificationCenter.default.post(name: .appListNavigateUp, object: nil)
    }
  }

  @objc private func handleMenuQuitApp() {
    NSApplication.shared.terminate(self)
  }

  private func hideApp() {
    window?.close()
    window = nil
    // This causes all the windows(belonging to this app) to be hidden
    // NSApp.hide(nil)
  }

  private func createWindow() {
    if window == nil {
      let contentView = ContentView().environmentObject(self)

      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
        styleMask: [.titled, .fullSizeContentView],
        backing: .buffered, defer: false
      )
      window?.delegate = self
      window?.isReleasedWhenClosed = false
      window?.contentView = NSHostingView(rootView: contentView.frame(width: 500, height: 450))
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
}
