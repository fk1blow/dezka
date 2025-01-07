//
//  AppDelegate.swift
//  Dezka
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem!
  private var window: NSWindow?
  private let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  private let mainCoordinator = MainCoordinator()

  override init() {
    super.init()
  }

  func applicationDidFinishLaunching(_: Notification) {
    if !isPreview {
      createMenu()
    }

    mainCoordinator.handleHotkey()
  }

  private func createMenu() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "circle.circle", accessibilityDescription: "Menu Icon"
      )
    }
    // if let button = statusItem.button {
    //   button.image = NSImage(named: "AppIcon")  // Replace "YourIconName" with the name of your asset
    //   button.image?.size = NSSize(width: 16, height: 16)  // Adjust size if needed
    // }

    let menu = NSMenu()
    menu.addItem(
      NSMenuItem(title: "Quit", action: #selector(handleMenuQuitApp), keyEquivalent: "q"))
    statusItem.menu = menu
  }

  @objc private func handleMenuQuitApp() {
    NSApplication.shared.terminate(self)
  }
}
