//
//  SettingsScreen.swift
//  Dezka
//
//  Created by Dragos Tudorache on 30.12.2024.
//

import KeyboardShortcuts
import SwiftUI

struct SettingsScreen: View {
  var body: some View {
    Form {
      KeyboardShortcuts.Recorder("Dezka Hotkey/Navigate next:", name: .dezkaHotkeyNext)
      KeyboardShortcuts.Recorder("Dezka Hotkey/Navigate previous:", name: .dezkaHotkeyPrevious)
    }
  }
}
