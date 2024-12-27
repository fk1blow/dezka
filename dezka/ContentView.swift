//
//  ContentView.swift
//  cazhan
//

import AppKit
import ApplicationServices
import SwiftUI

struct ContentView: View {
  @State private var searchTerm = ""

  private var isPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }

  var body: some View {
    if isPreview {
      VStack(alignment: .center, spacing: 0, content: {
        ZStack(
          alignment: .leading,
          content: {
            SearchInputView(text: $searchTerm)
              .padding(.horizontal, 10)
              .offset(x: 0, y: -8)
              .overlay(VStack { Divider().background(Color(hex: "#383838")).offset(x: 0, y: 29) })
              .frame(height: 45)

            if searchTerm.isEmpty {
              Text("Search for apps...")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(hex: "#767676"))
                .offset(x: 15, y: 4)
                .frame(height: 20)
            }
          }
        )

        Spacer()

        AppListView()

        AppFooterView()
      })
      .background(Color(hex: "#232323"))
    } else {
      VStack(alignment: .center, spacing: 0, content: {
        ZStack(
          alignment: .topLeading,
          content: {
            SearchInputView(text: $searchTerm)
              .frame(height: 20)
              .padding(.horizontal, 10)
              .offset(x: 0, y: 6)
              .overlay(VStack { Divider().background(Color(hex: "#383838")).offset(x: 0, y: 29) })
              .frame(height: 45)

            if searchTerm.isEmpty {
              Text("Search for apps...")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color(hex: "#767676"))
                .offset(x: 15, y: 18)
                .frame(height: 20)
            }
          }
        )

        Spacer()

        AppListView()

        AppFooterView()
      })
      .padding(EdgeInsets(top: -30, leading: 0, bottom: 0, trailing: 0))
      .background(Color(hex: "#232323"))
    }
  }
}

#Preview {
  ContentView()
}