//
//  ViewCoordinator.swift
//  Dezka
//

import Combine
import SwiftUI

class ViewCoordinator: NSObject, NSWindowDelegate {
  private var timer: Timer?
  private var statusItem: NSStatusItem!
  private var window: NSWindow?
  private var appSwitcher: (AppSwitcherUI & AppSwitcherNavigation)!
  private var activationCancellable: AnyCancellable? = nil
  private var globalClickMonitor: Any?

  init(appSwitcher: AppSwitcher) {
    super.init()
    self.appSwitcher = appSwitcher
    monitorAppSwitcherStateChanges()
    monitorOutsideClicks()
  }

  func showSwitcherWindow() {
    stopTimer()

    timer = Timer.scheduledTimer(withTimeInterval: 0.150, repeats: false) { _ in
      self.createWindow()
    }
  }

  func hideSwitcherWindow() {
    stopTimer()
    hideApp()
  }

  // Although we're not calling `NSApp.activate(ignoringOtherApps: true)` when creating the window,
  // if the app window ever gets focused(eg: mouse click) then loses it, the `windowDidResignKey`
  // would still be called
  func windowDidResignKey(_: Notification) {
    hideSwitcherWindow()
  }

  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  private func hideApp() {
    guard window != nil else { return }

    window?.close()
    window = nil
    NSApp.deactivate()
  }

  private func createWindow() {
    if window == nil {
      let appSwitcherContentViewModel = AppSwitcherContentViewModel(
        appSwitcher: appSwitcher
      )
      let appSwitcherContentView = AppSwitcherContentView(
        appSwitcherContentViewModel: appSwitcherContentViewModel
      )

      window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
        styleMask: [.titled, .fullSizeContentView],
        backing: .buffered, defer: false
      )
      // window?.alphaValue = 0
      window?.delegate = self
      window?.isReleasedWhenClosed = false
      window?.contentView = NSHostingView(
        rootView: appSwitcherContentView.frame(width: 500, height: 450))
      window?.titleVisibility = .hidden
      window?.titlebarAppearsTransparent = true
      window?.isMovable = false
      window?.center()
    }

    // Disabled so that when appearing, the window doesn't steal focus from the current app
    // NSApp.activate(ignoringOtherApps: true)
    window?.makeKeyAndOrderFront(nil)
    window?.orderFrontRegardless()

    // Animate the fade-in
    // NSAnimationContext.runAnimationGroup { context in
    //   guard let window = window else { return }
    //   context.duration = 0.02  // Similar timing to App Switcher
    //   context.timingFunction = CAMediaTimingFunction(name: .easeIn)

    //   window.animator().alphaValue = 1
    //   // window.animator().setFrame(window.frame.insetBy(dx: -10, dy: -10), display: true)  // Restore original size
    // }
  }

  private func monitorOutsideClicks() {
    globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [
      .leftMouseDown
    ]) { _ in
      guard let window = self.window else { return }

      let mouseLocation = NSEvent.mouseLocation
      let windowFrame = window.frame

      if windowFrame.contains(mouseLocation) {
        // clicked inside, should have focus and what not
      } else {
        self.hideSwitcherWindow()
        self.appSwitcher.appSwitcherShouldClose()
      }
    }
  }

  private func monitorAppSwitcherStateChanges() {
    activationCancellable = appSwitcher.cycleState.$state
      .sink { newState in
        if newState != .navigatingThroughApps {
          self.hideSwitcherWindow()
        }
      }
  }
}
