https://chatgpt.com/share/6773099d-fee0-8011-a759-6a5ebd45b97d


```swift
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
    private var appFocusTimestamps: [pid_t: Date] = [:]

    private var notificationCenter: NotificationCenter {
        NSWorkspace.shared.notificationCenter
    }

    init() {
        // Initialize the list with currently running applications
        updateRunningApplications()

        // Observe application launch notifications
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )

        // Observe application termination notifications
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidTerminate(_:)),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )

        // Observe application activation (focus) notifications
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    @objc private func applicationDidLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        if app.activationPolicy == .regular {
            DispatchQueue.main.async {
                self.runningApplications.append(app)
                self.sortApplicationsByFocusTime()
            }
        }
    }

    @objc private func applicationDidTerminate(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        DispatchQueue.main.async {
            self.runningApplications.removeAll { $0.processIdentifier == app.processIdentifier }
            self.appFocusTimestamps[app.processIdentifier] = nil
        }
    }

    @objc private func applicationDidActivate(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        DispatchQueue.main.async {
            // Update the focus timestamp for the app
            self.appFocusTimestamps[app.processIdentifier] = Date()
            self.sortApplicationsByFocusTime()
        }
    }

    private func updateRunningApplications() {
        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }

        DispatchQueue.main.async {
            self.runningApplications = apps
            // Initialize focus timestamps for all apps
            for app in apps {
                if self.appFocusTimestamps[app.processIdentifier] == nil {
                    self.appFocusTimestamps[app.processIdentifier] = Date.distantPast
                }
            }
            self.sortApplicationsByFocusTime()
        }
    }

    private func sortApplicationsByFocusTime() {
        runningApplications.sort { app1, app2 in
            let time1 = appFocusTimestamps[app1.processIdentifier] ?? Date.distantPast
            let time2 = appFocusTimestamps[app2.processIdentifier] ?? Date.distantPast
            return time1 > time2
        }
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
}

```
