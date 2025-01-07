//
//  DezkaApp.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import SwiftUI

@main
struct DezkaApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    //    WindowGroup {
    //      SettingsScreen()
    //    }
    Settings {
      EmptyView()
      //      SettingsScreen()
      //        .frame(width: 400, height: 300)
    }
  }
}
