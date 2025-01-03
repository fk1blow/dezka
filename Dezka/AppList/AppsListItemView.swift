//
//  AppsListItemView.swift
//  dezka
//

import SwiftUI

struct AppsListItemView: View {
  var app: NSRunningApplication
  var isSelected: Bool

  @State private var isHovering = false

  var body: some View {
    HStack(alignment: .center, spacing: 14) {
      if let icon = app.icon {
        Image(nsImage: icon)
          .resizable()
          .frame(width: 24, height: 24)
      }
      Text(getAppName())
        .id(getAppId())
        .font(Font.system(size: 12, weight: .medium))
        .foregroundStyle(Color(hex: "#F2F2F2"))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

      Text("a.I")
        .id(getAppId())
        .font(Font.system(size: 14, weight: .medium))
        .foregroundStyle(Color(hex: "#a8a8a8"))
//        .background(
//          Circle()
//            .fill(Color(hex: "#A8A8A8"))
//            .frame(width: 20, height: 20)
//        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(EdgeInsets(top: 9, leading: 6, bottom: 9, trailing: 6))
    .onHover(perform: { hovering in self.isHovering = hovering })
    .background(itemSelectedStyle())
    .cornerRadius(8)
  }

  private func isItemSelected() -> Bool {
    return isSelected || isHovering
  }

  private func itemSelectedStyle() -> Color {
    isSelected ? Color(hex: "#393939") : isHovering ? Color(hex: "#2B2B2B") : Color.clear
  }

  private func getAppName() -> String {
    return app.localizedName ?? ""
  }

  private func getAppId() -> String {
    app.bundleIdentifier ?? ""
  }
}
