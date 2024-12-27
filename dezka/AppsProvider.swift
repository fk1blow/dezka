//
//  AppsProvider.swift
//  dezka
//

import AppKit

struct StaticAppItem {
  let id: UUID
  let name: String
  let icon: NSImage
}

struct AppsProvider {
  static let staticApps: [StaticAppItem] = [
    StaticAppItem(
      id: UUID(),
      name: "iTerm2", icon: NSWorkspace.shared.icon(forFile: "/Applications/iTerm.app")),
    StaticAppItem(
      id: UUID(),
      name: "SomaFM", icon: NSWorkspace.shared.icon(forFile: "/Applications/SomaFM.app")),
    StaticAppItem(
      id: UUID(),
      name: "Finder",
      icon: NSWorkspace.shared.icon(forFile: "/System/Library/CoreServices/Finder.app")),
    StaticAppItem(
      id: UUID(),
      name: "Keymapp", icon: NSWorkspace.shared.icon(forFile: "/Applications/keymapp.app")),
    StaticAppItem(
      id: UUID(),
      name: "Code", icon: NSWorkspace.shared.icon(forFile: "/Applications/Visual Studio Code.app")),
    StaticAppItem(
      id: UUID(),
      name: "Transmission", icon: NSWorkspace.shared.icon(forFile: "/Applications/Transmission.app")
    ),
    StaticAppItem(
      id: UUID(),
      name: "Arc", icon: NSWorkspace.shared.icon(forFile: "/Applications/Arc.app")),
    StaticAppItem(
      id: UUID(),
      name: "Firefox", icon: NSWorkspace.shared.icon(forFile: "/Applications/Firefox.app")),
    StaticAppItem(
      id: UUID(),
      name: "GitHub Desktop",
      icon: NSWorkspace.shared.icon(forFile: "/Applications/GitHub Desktop.app")),
    StaticAppItem(
      id: UUID(),
      name: "Skitch", icon: NSWorkspace.shared.icon(forFile: "/Applications/Skitch.app")),
    StaticAppItem(
      id: UUID(),
      name: "ChatGPT", icon: NSWorkspace.shared.icon(forFile: "/Applications/ChatGPT.app")),
    StaticAppItem(
      id: UUID(),
      name: "Xcode", icon: NSWorkspace.shared.icon(forFile: "/Applications/Xcode.app")),
  ]
}
