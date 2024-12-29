//
//  DezkaApp.swift
//  dezka
//

import HotKey
import SwiftUI

@main
struct DezkaApp: App {
  private var dezkaMain = Dezka()
  @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

  init() {
    appDelegate.dezkaMain = dezkaMain
  }

  var body: some Scene {
    Settings {
      EmptyView()
    }
    .environmentObject(dezkaMain)
  }
}
