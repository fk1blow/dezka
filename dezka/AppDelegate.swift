//
//  AppDelegate.swift
//  cazhan
//

import Foundation
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem!
  var hotKey: HotKey?
  var window: NSWindow?

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Create the status bar item
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "circle.circle", accessibilityDescription: "Menu Icon")
    }

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
    statusItem.menu = menu

    // Set up the global hotkey
    hotKey = HotKey(key: .r, modifiers: [.shift, .control, .option, .command])
    hotKey?.keyDownHandler = {
      self.showWindow()
    }
  }

  @objc func quitApp() {
    NSApplication.shared.terminate(self)
  }

  func showWindow() {
    if window == nil {
      let contentView = ContentView()
      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
        styleMask: [.titled, .closable],
        backing: .buffered, defer: false
      )

      window?.contentView = NSHostingView(rootView: contentView)
      window?.isReleasedWhenClosed = false
//      window?.center()

      window?.styleMask.remove(.titled)
      window?.styleMask = [.titled, .fullSizeContentView]
      window?.contentView = NSHostingView(rootView: ContentView().frame(width: 600, height: 400))
      window?.titleVisibility = .hidden
      window?.titlebarAppearsTransparent = true
      window?.isMovable = false
      
      window?.center()
    }

    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationDidResignActive(_ notification: Notification) {
    print("applicationDidResignActivate")
    window?.close()
    NSApp.hide(nil)
    print("...hide app")
  }
}
