//
//  AppListView.swift
//  dezka
//

import SwiftUI

struct AppListView: View {
  var filterQuery: String
  var appsList: [NSRunningApplication]
  var navigationAtIndex: Int

  private var filteredAppsList: [NSRunningApplication] {
    return []
    //    if searchTerm.isEmpty {
    //      return appListManager.runningApplications ?? []
    //    }
    //
    //    let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
    //    if trimmedSearchTerm.isEmpty {
    //      return appListManager.runningApplications ?? []
    //    }
    //
    //    return appListManager.runningApplications.filter {
    //      $0.localizedName?
    //        .trimmingCharacters(in: .whitespacesAndNewlines)
    //        .lowercased()
    //        .contains(trimmedSearchTerm.lowercased())
    //        ?? false
    //    }
  }

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(appsList.indices), id: \.self) { index in
              AppsListItemView(
                app: appsList[index],
                isSelected: index == navigationAtIndex)
            }
          }
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 6, trailing: 0))
        .onChange(of: navigationAtIndex) { _, newValue in
          proxy.scrollTo(newValue)
        }
      }
    }
    .onChange(of: filterQuery) { oldValue, newValue in
      handleSearchTermChange(oldValue: oldValue, newValue: newValue)
    }
  }

  private func handleNavigate(isUpArrow: Bool) {
    // TODO: handle this scenario
    // if isUpArrow, appDelegate.appListManager.selectedIndex > 0 {
    //   selectedIndex -= 1
    // } else if !isUpArrow, appDelegate.appListManager.selectedIndex < filteredAppsList.count - 1 {
    //   selectedIndex += 1
    // }
    if isUpArrow {
      //      appListManager.navigateTo(direction: .previous)
    } else {
      //      appListManager.navigateTo(direction: .next)
    }
  }

  private func handleSwitchToApp(at selectedIndex: Int) {
    // guard !filteredAppsList.isEmpty,
    //       let selectedApp = filteredAppsList[selectedIndex] as NSRunningApplication?
    // else {
    //   return
    // }

    //    appListManager.switchFocusTo(where: selectedApp)
  }

  private func handleSearchTermChange(oldValue: String, newValue: String) {
    if !oldValue.isEmpty && newValue.isEmpty {
      // selectedIndex = 0
      //      appListManager.navigateToFirst()
    }
    // TODO: handle this scenario
    // if !newValue.isEmpty && selectedIndex > filteredAppsList.count - 1 {
    if !newValue.isEmpty {
      // selectedIndex = 0
      //      appListManager.navigateToFirst()
    }
  }
}
