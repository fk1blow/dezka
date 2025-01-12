//
//  AppSwitcherContentViewModel.swift
//  Dezka
//

import SwiftUI

class AppSwitcherContentViewModel: ObservableObject {
  let appSwitcher: AppSwitcherUI & AppSwitcherNavigation

  @Published private(set) var visibleApps: [NSRunningApplication] = []
  @Published private(set) var appSearchQuery: String = ""
  @Published private(set) var navigationIndex: Int = 0

  init(appSwitcher: AppSwitcherUI & AppSwitcherNavigation) {
    self.appSwitcher = appSwitcher

    setupObservation()
  }

  private func setupObservation() {
    appSwitcher.navigationState.map(\.visibleApps)
      .assign(to: &$visibleApps)

    appSwitcher.navigationState.map(\.appSearchQuery)
      .assign(to: &$appSearchQuery)

    appSwitcher.navigationState.map(\.navigationIndex)
      .assign(to: &$navigationIndex)
  }
}
