//
//  AppListView.swift
//  dezka
//
import SwiftUI

struct AppListView: View {
  @Binding var searchTerm: String
  @State private var selectedIndex: Int = 0
  @EnvironmentObject var appDelegate: AppDelegate

  private var filteredAppsList: [NSRunningApplication] {
    if searchTerm.isEmpty {
      return appDelegate.runningApps
    }

    let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedSearchTerm.isEmpty {
      return appDelegate.runningApps
    }

    return appDelegate.runningApps.filter {
      $0.localizedName?
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
        .contains(trimmedSearchTerm.lowercased())
        ?? false
    }
  }

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(filteredAppsList.indices), id: \.self) { index in
              AppsListItemView(app: filteredAppsList[index], isSelected: selectedIndex == index)
            }
          }
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 6, trailing: 0))
        .onChange(of: selectedIndex) { _, newValue in
          proxy.scrollTo(newValue)
        }
      }
    }
    .onChange(of: searchTerm) { oldValue, newValue in
      handleSearchTermChange(oldValue: oldValue, newValue: newValue)
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListNavigateUp)) { _ in
      handleNavigate(isUpArrow: true)
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListNavigateDown)) { _ in
      handleNavigate(isUpArrow: false)
    }
    .onReceive(NotificationCenter.default.publisher(for: .applicationWillHide)) { _ in
      selectedIndex = 0
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListItemSelect)) { _ in
      if !filteredAppsList.isEmpty {
        handleSwitchToApp(filteredAppsList[selectedIndex])
      }
    }
  }

  private func handleNavigate(isUpArrow: Bool) {
    if isUpArrow, selectedIndex > 0 {
      selectedIndex -= 1
    } else if !isUpArrow, selectedIndex < filteredAppsList.count - 1 {
      selectedIndex += 1
    }
  }

  private func handleSwitchToApp(_ app: NSRunningApplication) {
    app.activate(options: [.activateAllWindows])
  }

  private func handleSearchTermChange(oldValue: String, newValue: String) {
    if !oldValue.isEmpty && newValue.isEmpty {
      selectedIndex = 0
    }
    if !newValue.isEmpty && selectedIndex > filteredAppsList.count - 1 {
      selectedIndex = 0
    }
  }
}
