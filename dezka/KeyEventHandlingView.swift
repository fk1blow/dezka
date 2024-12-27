//
//  KeyEventHandlingView.swift
//  cazhan
//
//  Created by Dragos Tudorache on 25.12.2024.
//

import SwiftUI
import Foundation

struct KeyEventHandlingView: NSViewRepresentable {
  let onKeyDownEvent: ((NSEvent) -> Void)?
  let onKeyUpEvent: ((NSEvent) -> Void)?

  init(onKeyDownEvent: ((NSEvent) -> Void)?, onKeyUpEvent: ((NSEvent) -> Void)?) {
    self.onKeyDownEvent = onKeyDownEvent
    self.onKeyUpEvent = onKeyUpEvent
  }

  init(onKeyDownEvent: ((NSEvent) -> Void)?) {
    self.onKeyDownEvent = onKeyDownEvent
    self.onKeyUpEvent = nil
  }

  func makeNSView(context: Context) -> NSView {
    let view = CustomKeyEventView()
    view.onKeyDownEvent = onKeyDownEvent ?? nil
    view.onKeyUpEvent = onKeyUpEvent ?? nil

    DispatchQueue.main.async {
      view.window?.makeFirstResponder(view) // Set the view as the first responder
    }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {}

  class CustomKeyEventView: NSView {
    var onKeyDownEvent: ((NSEvent) -> Void)?
    var onKeyUpEvent: ((NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool {
      true
    }

    override func becomeFirstResponder() -> Bool {
      return true
    }

    override func keyDown(with event: NSEvent) {
      onKeyDownEvent?(event)
    }

    override func keyUp(with event: NSEvent) {
      onKeyUpEvent?(event)
    }
  }
}
