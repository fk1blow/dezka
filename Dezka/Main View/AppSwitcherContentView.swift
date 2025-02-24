//
//  AppSwitcherContentView.swift
//  Dezka
//

import SwiftUI

struct AppSwitcherContentView: View {
  @ObservedObject var appSwitcherContentViewModel: AppSwitcherContentViewModel

  @State private var searchTerm = ""

  var body: some View {
    VStack(
      alignment: .center, spacing: 0,
      content: {
        // ZStack(
        //   alignment: .topLeading,
        //   content: {
        //     SearchInputView(text: $searchTerm)
        //       .frame(height: 20)
        //       .padding(.horizontal, 10)
        //       .offset(x: 0, y: 6)
        //       .overlay(VStack { Divider().background(Color(hex: "#383838")).offset(x: 0, y: 29) })
        //       .frame(height: 45)

        //     if searchTerm.isEmpty {
        //       Text("Search for apps...")
        //         .font(.system(size: 16, weight: .regular))
        //         .foregroundStyle(Color(hex: "#767676"))
        //         .offset(x: 15, y: 18)
        //         .frame(height: 20)
        //     }
        //   }
        // )

        Spacer()

        AppListView(
          filterQuery: appSwitcherContentViewModel.appSearchQuery,
          appsList: appSwitcherContentViewModel.visibleApps,
          navigationAtIndex: appSwitcherContentViewModel.navigationIndex
        )

        // AppFooterView()
      }
    )
    // alternative background
    // .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#0D0D0D")))
    .padding(
      ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        ? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        : EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0)
    )
    .background(Color(hex: "#1E1E1E"))
    .onReceive(NotificationCenter.default.publisher(for: .applicationWillHide)) { _ in
      searchTerm = ""
    }
    .onReceive(NotificationCenter.default.publisher(for: .appSearchClear)) { _ in
      if searchTerm.isEmpty {
        NotificationCenter.default.post(name: .applicationShouldHide, object: self)
        return
      }
      searchTerm = ""
    }
  }
}
