//
//  RunningAppsMonitor.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import Combine
import SwiftUI

class RunningAppsMonitor: ObservableObject {
  @Published var runningApplications: [NSRunningApplication] = []

  private var notificationCenter: NotificationCenter {
    NSWorkspace.shared.notificationCenter
  }

  init() {
    updateRunningApplications()

    notificationCenter.addObserver(
      self,
      selector: #selector(applicationDidLaunch(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )

    notificationCenter.addObserver(
      self,
      selector: #selector(applicationDidTerminate(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )
  }

  @objc private func applicationDidLaunch(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    else {
      return
    }

    if app.activationPolicy == .regular {
      DispatchQueue.main.async {
        self.runningApplications.append(app)
      }
    }
  }

  @objc private func applicationDidTerminate(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    else {
      return
    }

    DispatchQueue.main.async {
      self.runningApplications.removeAll { $0.processIdentifier == app.processIdentifier }
    }
  }

  private func updateRunningApplications() {
    runningApplications = NSWorkspace.shared.runningApplications.filter {
      $0.activationPolicy == .regular
    }
  }

  deinit {
    notificationCenter.removeObserver(self)
  }
}
