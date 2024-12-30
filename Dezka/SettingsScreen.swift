//
//  SettingsScreen.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
  var body: some View {
    Form {
      KeyboardShortcuts.Recorder("Dezka Hotkey:", name: .dezkaHotkey)
    }
  }
}
