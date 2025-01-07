//
//  ActivationTransitionMonitor.swift
//  Dezka
//

import Cocoa

class ActivationTransitionMonitor: NSObject {
  weak var delegate: AppSwitcherMonitoringDelegate?

  var isMonitoringEnabled: Bool = false

  private var isAnimating = false
  private var activeSpaceChangeObserver: Any?
  private var pollTimer: Timer?
  private var frameBeforeTransition: CGRect?
  private var pollStartTime: TimeInterval = 0
  private let maxPollDuration: TimeInterval = 1.0
  private let pollInterval: TimeInterval = 0.01
  private var unchangedFrameCount = 0
  private let requiredStableFrames = 3
  private var pendingSpaceChange = false
  private var lastActivatedApp: NSRunningApplication?

  override init() {
    super.init()
    setupObservers()
  }

  func enable() {
    isMonitoringEnabled = true
  }

  func disable() {
    isMonitoringEnabled = false
  }

  func setupObservers() {
    // Observe app activation
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard let strongSelf = self, strongSelf.isMonitoringEnabled else {
        return
      }
      self?.handleApplicationActivated(notification)
    }

    // Observe space changes
    activeSpaceChangeObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.activeSpaceDidChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let strongSelf = self, strongSelf.isMonitoringEnabled else {
        return
      }
      self?.handleSpaceChange()
    }
  }

  private func handleApplicationActivated(_ notification: Notification) {
    guard
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    else {
      return
    }

    // Immediately check if app is on current space
    if isAppVisibleOnCurrentSpace(app) {
      Debug.log("App activated on current space: \(app.localizedName ?? "Unknown")")
      // delegate?.appSwitcher(self, didActivateAppOnSameSpace: app)
      delegate?.didActivateAppOnSameSpace(app: app)
      return  // Return immediately for same-space activation
    }

    // Different space case
    Debug.log("App activated from different space: \(app.localizedName ?? "Unknown")")
    lastActivatedApp = app
    pendingSpaceChange = true
    delegate?.willActivateAppOnDifferentSpace(app: app)
  }

  private func isAppVisibleOnCurrentSpace(_ app: NSRunningApplication) -> Bool {
    guard
      let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]]
    else {
      return false
    }

    return windowList.contains { window in
      let ownerPID = window[kCGWindowOwnerPID as String] as? pid_t
      let layer = window[kCGWindowLayer as String] as? Int
      return ownerPID == app.processIdentifier && layer == 0
    }
  }

  private func handleSpaceChange() {
    guard pendingSpaceChange, let app = lastActivatedApp else {
      return
    }

    isAnimating = true
    pollStartTime = ProcessInfo.processInfo.systemUptime
    Debug.log("Space change detected, starting polling")

    startPolling(for: app)
  }

  private func startPolling(for app: NSRunningApplication) {
    if let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
      as? [[String: Any]],
      let firstWindow = windowList.first(where: {
        ($0[kCGWindowOwnerPID as String] as? pid_t) == app.processIdentifier
      })
    {
      frameBeforeTransition = CGRect(
        dictionaryRepresentation: firstWindow[kCGWindowBounds as String] as! CFDictionary)
    }

    pollTimer?.invalidate()
    pollTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) {
      [weak self] _ in
      self?.checkTransitionComplete()
    }
  }

  private func checkTransitionComplete() {
    let currentTime = ProcessInfo.processInfo.systemUptime

    // Check for timeout
    if currentTime - pollStartTime > maxPollDuration {
      stopPolling()
      return
    }

    guard let app = lastActivatedApp,
      let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]],
      let firstWindow = windowList.first(where: {
        ($0[kCGWindowOwnerPID as String] as? pid_t) == app.processIdentifier
      }),
      let frameBeforeTransition = frameBeforeTransition
    else {
      stopPolling()
      return
    }

    let currentFrame = CGRect(
      dictionaryRepresentation: firstWindow[kCGWindowBounds as String] as! CFDictionary)!

    if currentFrame == frameBeforeTransition {
      unchangedFrameCount += 1
    } else {
      unchangedFrameCount = 0
      self.frameBeforeTransition = currentFrame
    }

    if unchangedFrameCount >= requiredStableFrames {
      stopPolling()
      // delegate?.appSwitcher(self, didFinishSpaceTransitionFor: app)
      delegate?.didFinishSpaceTransitionFor(app: app)
    }
  }

  private func stopPolling() {
    pollTimer?.invalidate()
    pollTimer = nil
    frameBeforeTransition = nil
    isAnimating = false
    unchangedFrameCount = 0
    pendingSpaceChange = false
    lastActivatedApp = nil
  }

  deinit {
    stopPolling()
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    if let observer = activeSpaceChangeObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
  }
}
