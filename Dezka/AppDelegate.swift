//
//  AppDelegate.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import Cocoa
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
  }

  func applicationDidFinishLaunching(_: Notification) {
    if !isPreview {
      createMenu()
    }

    KeyboardShortcuts.onKeyDown(for: .dezkaHotkey) { [self] in
      // guard appSwitcher.isActive == false else { return }

      // print("Dezka onKeyDown")

      // NSApp.activate(ignoringOtherApps: true)
      // KeyboardShortcuts.disable(.dezkaHotkey)
      // This is not actually "enabling" of the appSwitcher
      // TODO: rename
      appSwitcher.switchToNextApp()

      // createWindow()
    }

    // let foo = getWindowsList()
    // print(foo)
  }

  func appSwitcherDidFinish() {
    // NSApp.deactivate()
    // KeyboardShortcuts.enable(.dezkaHotkey)
    // appSwitcher.disable()
    print("_____________________________")
  }

  func windowDidResignKey(_: Notification) {
    print("windowDidResignKey")
    hideApp()
    KeyboardShortcuts.enable(.dezkaHotkey)
    // appSwitcher.disable()
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

  private func getWindowsList() -> [WindowDef] {
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))

    guard let infoList = windowsListInfo as? [[String: Any]] else {
      return []
    }

    let visibleWindows = infoList.filter { windowInfo in
      guard let layer = windowInfo["kCGWindowLayer"] as? Int,
            let ownerName = windowInfo["kCGWindowOwnerName"] as? String
      else {
        return false
      }
      return layer == 0 && ownerName != "WindowManager"
    }

    return visibleWindows.map { windowInfo in
      guard let name = windowInfo["kCGWindowOwnerName"] as? String,
            let wid = windowInfo["kCGWindowNumber"] as? Int,
            let pid = windowInfo["kCGWindowOwnerPID"] as? Int
      else {
        fatalError("Missing window property")
      }

      // So far, Google Chrome is the only alias I want to hardcode
      var alias = String(name.first!).uppercased()
      if name == "Google Chrome" {
        alias = "C"
      }

      let matchedApp = NSWorkspace.shared.runningApplications.filter { app in
        app.processIdentifier == pid
      }.first

      guard let icon = matchedApp?.icon else {
        fatalError("Could not retrieve window icon.")
      }

      return WindowDef(
        name: name,
        wid: wid,
        pid: pid,
        alias: alias,
        icon: icon
      )
    }.uniqued()
  }
}

struct WindowDef: Identifiable, Hashable {
  let id = UUID()

  /// Name of the window.
  let name: String

  /// ID of the window.
  let wid: Int

  /// Process ID owning the window.
  let pid: Int

  /// Alias name for the window.
  let alias: String

  /// Icon image for the window.
  let icon: NSImage

  // MARK: Initialize

  /// Initialize a new window definition.
  ///
  /// - Parameters:
  ///   - name: Name of the window.
  ///   - wid: ID of the window.
  ///   - pid: ID of the process owning the window.
  ///   - alias: Alias name for the window.
  ///   - icon: Icon image for the window.
  init(
    name: String = "",
    wid: Int = -1,
    pid: Int = -1,
    alias: String = "",
    icon: NSImage
  ) {
    self.name = name
    self.wid = wid
    self.pid = pid
    self.alias = alias
    self.icon = icon
  }

  // MARK: Hashable

  func hash(into hasher: inout Hasher) {
    hasher.combine(pid)
  }

  static func == (left: WindowDef, right: WindowDef) -> Bool {
    return left.pid == right.pid
  }
}

extension Sequence where Element: Hashable {
  func uniqued() -> [Element] {
    var set = Set<Element>()
    return filter { set.insert($0).inserted }
  }
}
