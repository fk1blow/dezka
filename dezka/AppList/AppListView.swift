//
//  AppListView.swift
//  dezka
//
import SwiftUI

struct AppListView: View {
  @Binding var searchTerm: String
  @State private var runningApps: [NSRunningApplication] = []
  @State private var selectedIndex: Int = 0

  private var filteredAppsList: [NSRunningApplication] {
    if searchTerm.isEmpty {
      return runningApps
    }
    return runningApps.filter {
      $0.localizedName?.lowercased().contains(searchTerm.lowercased()) ?? false
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
        .scrollIndicators(.hidden)
        .onChange(of: selectedIndex) { _, newValue in
          proxy.scrollTo(newValue)
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListNavigateUp)) { _ in
      navigate(isUpArrow: true)
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListNavigateDown)) { _ in
      navigate(isUpArrow: false)
    }
    .onReceive(NotificationCenter.default.publisher(for: .appListItemSelect)) { _ in
      if !filteredAppsList.isEmpty {
        switchToApp(filteredAppsList[selectedIndex])
      }
    }
    .onAppear {
      fetchRunningApps()
    }
  }

  private func navigate(isUpArrow: Bool) {
    if isUpArrow, selectedIndex > 0 {
      selectedIndex -= 1
    } else if !isUpArrow, selectedIndex < filteredAppsList.count - 1 {
      selectedIndex += 1
    }
  }

  private func fetchRunningApps() {
    runningApps = NSWorkspace.shared.runningApplications.filter { app in
      // Include apps with a user interface (and exclude background apps)
      app.activationPolicy == .regular
    }
  }

  private func switchToApp(_ app: NSRunningApplication) {
    app.activate(options: [.activateAllWindows])
  }
}
