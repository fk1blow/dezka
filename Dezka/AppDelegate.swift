//
//  AppDelegate.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import KeyboardShortcuts
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, ObservableObject, AppSwitcherDelegate {
  private var statusItem: NSStatusItem!
  private var window: NSWindow?
  private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  private let appSwitcher = AppSwitcher()

  override init() {
    super.init()
    appSwitcher.delegate = self
    // let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
    // AXIsProcessTrustedWithOptions(options)
//    appSwitcher.delegate = self
  }

  func applicationDidFinishLaunching(_: Notification) {
    if !isPreview {
      createMenu()
    }

    KeyboardShortcuts.onKeyDown(for: .dezkaHotkey) { [self] in
      NSApp.activate(ignoringOtherApps: true)
      KeyboardShortcuts.disable(.dezkaHotkey)
      appSwitcher.enable()

      // createWindow()
    }
  }

  func appSwitcherDidFinish() {
    NSApp.deactivate()
    KeyboardShortcuts.enable(.dezkaHotkey)
    appSwitcher.disable()
    print("_____________________________")
  }

  func windowDidResignKey(_: Notification) {
    print("windowDidResignKey")
    hideApp()
    KeyboardShortcuts.enable(.dezkaHotkey)
    appSwitcher.disable()
//    switcherActivationMonitor.stopMonitor()
    // This should first check if the switcher is still active
    // b/c it might trigger before the `switcherActivationDidEnd`
    // appListManager.navigateToFirst()
  }

//   func switcherActivationDidEnd() {
//     print("switcherActivationDidEnd")
//     hideApp()
//     // NotificationCenter.default.post(name: .appListItemSelect, object: nil)
//     // appSwitcher.disable()
  // //    appListManager.switchFocusToSelected()
//     // KeyboardShortcuts.enable(.dezkaHotkey)
//   }

//  func switcherNavigationDidTrigger(to direction: SwitcherNavigationDirection) {
//    switch direction {
//    case .next:
//      appListManager.navigateTo(direction: .next)
//    // NotificationCenter.default.post(name: .appListNavigateDown, object: nil)
//    case .previous:
//      appListManager.navigateTo(direction: .previous)
//      // NotificationCenter.default.post(name: .appListNavigateUp, object: nil)
//    }
//  }

  @objc private func handleMenuQuitApp() {
    NSApplication.shared.terminate(self)
  }

  private func hideApp() {
    window?.close()
    window = nil
    // This causes all the windows(belonging to this app) to be hidden
    // NSApp.hide(nil)
  }

  // split this into : activateWindow and activateApp
  private func createWindow() {
    if window == nil {
      // let contentView = ContentView().environmentObject(self)
//      let contentView = ContentView().environmentObject(appListManager)
      let contentView = ContentView()

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
