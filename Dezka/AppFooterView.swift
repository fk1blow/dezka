//
//  AppFooterView.swift
//  cazhan
//

import SwiftUI

struct AppFooterView: View {
  var body: some View {
    HStack(alignment: .center, content: {
      Image(systemName: "circle.circle")
        .font(.system(size: 14, weight: .light))
        .foregroundStyle(Color(hex: "#767676"))

//      Spacer(minLength: 20)

//      Text("Made with ♥️ by fk1blow")
//        .font(.system(size: 10, weight: .regular))
//        .foregroundStyle(Color(hex: "#767676"))
//        .frame(maxWidth: .infinity, alignment: .leading)

//      HStack(alignment: .center, spacing: 14, content: {
//        Text("Mode:")
//          .font(.system(size: 12, weight: .medium))
//          .foregroundStyle(Color(hex: "#F2F2F2"))
//
//        HStack(alignment: .center, spacing: 10, content: {
//          Image(systemName: "magnifyingglass")
//            .font(.system(size: 11, weight: .semibold))
//            .foregroundStyle(Color(hex: "#A8A8A8"))
//            .background(
//              Rectangle()
//                .fill(Color(hex: "#3C3C3C"))
//                .frame(width: 24, height: 20)
//                .cornerRadius(4)
//            )
//
//          Text("Swap")
//            .font(.system(size: 12, weight: .medium))
//            .foregroundStyle(Color(hex: "#A8A8A8"))
//        })
//      })

      HStack(alignment: .center, spacing: 14, content: {
        Text("Open app")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(Color(hex: "#F2F2F2"))

        Image(systemName: "arrow.turn.down.left")
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(Color(hex: "#A8A8A8"))
          .background(
            Rectangle()
              .fill(Color(hex: "#3C3C3C"))
              .frame(width: 24, height: 20)
              .cornerRadius(4)
          )
      })
      .frame(maxWidth: .infinity, alignment: .trailing)

    })
    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 32))
    .frame(maxWidth: .infinity, maxHeight: 40)
    .background(Color(hex: "#282828"))
    .overlay(
      Rectangle()
        .frame(width: nil, height: 1, alignment: .top)
        .foregroundColor(Color(hex: "#3C3C3C")), alignment: .top
    )
  }
}
