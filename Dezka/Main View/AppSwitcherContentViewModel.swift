//
//  AppSwitcherContentViewModel.swift
//  Dezka
//

import SwiftUI

class AppSwitcherContentViewModel: ObservableObject {
  let appSwitcher: AppSwitcherUI & AppSwitcherNavigation

  @Published private(set) var appsList: [NSRunningApplication] = []
  @Published private(set) var filterQuery: String = ""
  @Published private(set) var navigationAtIndex: Int = 0

  init(appSwitcher: AppSwitcherUI & AppSwitcherNavigation) {
    self.appSwitcher = appSwitcher

    setupObservation()
  }

  private func setupObservation() {
    appSwitcher.navigationState.map(\.visibleApps)
      .assign(to: &$appsList)

    appSwitcher.navigationState.map(\.appSearchQuery)
      .assign(to: &$filterQuery)

    appSwitcher.navigationState.map(\.navigationIndex)
      .assign(to: &$navigationAtIndex)
  }
}
