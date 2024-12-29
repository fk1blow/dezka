//
//  AppDelegate.swift
//  dezka
//

import Foundation
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var dezkaMain: Dezka?
  var statusItem: NSStatusItem!

  let notificationCenter = NotificationCenter.default

  func applicationDidFinishLaunching(_ notification: Notification) {
    buildStatusBarMenu()

    dezkaMain?.launchApplication()
  }

  func applicationDidResignActive(_ notification: Notification) {
    dezkaMain?.deactivateApplication()
  }

  func applicationWillBecomeActive(_ notification: Notification) {
    dezkaMain?.fetchRunningApps()
  }

  private func buildStatusBarMenu() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "circle.circle", accessibilityDescription: "Menu Icon"
      )
    }

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
    statusItem.menu = menu
  }

  @objc private func quitApp() {
    NSApplication.shared.terminate(self)
  }
}
