//
//  DezkaApp.swift
//  dezka
//

import HotKey
import SwiftUI

// @main
// struct DezkaApp: App {
//  var body: some Scene {
//    WindowGroup {
//      ContentView()
//    }
//  }
// }

@main
struct DezkaApp: App {
  // these 2 are the same
//  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

  var body: some Scene {
    Settings {
      EmptyView()
    }
  }
}
