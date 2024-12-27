//
//  cazhanApp.swift
//  dezka
//
//  Created by Dragos Tudorache on 22.12.2024.
//

import HotKey
import SwiftUI

@main
struct DezkaApp: App {
  @NSApplicationDelegateAdaptor private var appDelegate: AppDelegatePreviews

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear(perform: {
          let localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            print(event)
            return event
          }
        })
    }
  }

  class AppDelegatePreviews: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
      if let window = NSApplication.shared.windows.first {
        window.styleMask.remove(.titled)
        window.styleMask = [.titled, .fullSizeContentView]
        window.contentView = NSHostingView(rootView: ContentView().frame(width: 500, height: 300))
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = false
        window.makeKeyAndOrderFront(nil)
      }
    }
  }
}

// This works when launching the app(not xcode preview)
// @main
// struct DezkaApp: App {
//  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//
//  var body: some Scene {
//    Settings {
//      EmptyView()
//    }
//  }
// }
