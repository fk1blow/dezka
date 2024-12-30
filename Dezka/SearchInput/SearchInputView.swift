//
//  SearchInputView.swift
//  dezka
//

import AppKit
import ApplicationServices
import SwiftUI

struct SearchInputView: NSViewRepresentable {
  @Binding var text: String

  let notificationCenter = NotificationCenter.default

  func makeNSView(context: Context) -> NSTextView {
    let view = RichTextFieldExtended()
    view.delegate = context.coordinator
    view.isRichText = false // Plain text only
    view.isEditable = true
    view.string = text
    view.isEditable = false

    // Set default attributes
    applyDefaultAttributes(to: view)

    // Configure NSTextView for cursor and behavior
    view.allowsUndo = true
    view.usesFindPanel = true

    // This search input should be focuse only on demand,
    // when toggling between "switch" and "search" modes
    DispatchQueue.main.async {
      view.window?.makeFirstResponder(view)
    }

    addViewEventHandlers(to: view)

//    notificationCenter.addObserver(
//      self,
//      selector: #selector(context.coordinator.handleAppChangeToSearchMode),
//      name: .appModeChangeToSearchMode,
//      object: nil
//    )

    return view
  }

  func updateNSView(_ nsView: NSTextView, context: Context) {
    // Synchronize SwiftUI state to NSTextView only if needed
    if nsView.string != text {
      nsView.string = text
      applyDefaultAttributes(to: nsView)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  private func addViewEventHandlers(to textView: RichTextFieldExtended) {
    textView.onArrowDownEvent = {
      NotificationCenter.default.post(name: .appListNavigateDown, object: self)
    }
    textView.onArrowUpEvent = {
      NotificationCenter.default.post(name: .appListNavigateUp, object: self)
    }
    textView.onEnterPressEvent = {
      NotificationCenter.default.post(name: .appListItemSelect, object: self)
    }
    textView.onEscPressEvent = {
      NotificationCenter.default.post(name: .appSearchClear, object: self)
    }
    textView.onSlashPressEvent = {
      textView.isEditable = true
    }
  }

  private func applyDefaultAttributes(to textView: NSTextView) {
    // Apply system font attributes to the entire string
    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 16, weight: .regular),
      .foregroundColor: NSColor.white,
    ]
    textView.textStorage?.setAttributes(
      attributes, range: NSRange(location: 0, length: textView.string.count)
    )
  }

  // Text View Delegate
  //
  class Coordinator: NSObject, NSTextViewDelegate {
    var parent: SearchInputView

    init(_ parent: SearchInputView) {
      self.parent = parent
    }

    func textDidChange(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else { return }

      // Update the SwiftUI state with the new text
      parent.text = textView.string
      // Reapply attributes after changes
      parent.applyDefaultAttributes(to: textView)
    }

//    @objc func handleAppChangeToSearchMode() {
//      print("fooooooooo")
//    }

    //    func textViewDidBeginEditing(_ textView: NSTextView) {
    //      if textView.string == "Search..." {
    //        textView.string = "Search..."
    //        textView.textColor = NSColor.textColor
    //      }
    //    }
    //
    //    func textViewDidEndEditing(_ textView: NSTextView) {
    //      if textView.string.isEmpty {
    //        textView.string = "Search..."
    //        textView.textColor = NSColor.placeholderTextColor
    //      }
    //    }
  }
}

private class RichTextFieldExtended: NSTextView {
  var onArrowUpEvent: (() -> Void)?
  var onArrowDownEvent: (() -> Void)?
  var onEnterPressEvent: (() -> Void)?
  var onEscPressEvent: (() -> Void)?
  var onSlashPressEvent: (() -> Void)?

  init() {
    let textView = NSTextView(frame: .zero)
    super.init(frame: textView.frame, textContainer: textView.textContainer)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 44:
      onSlashPressEvent?()
      return
    case 53:
      onEscPressEvent?()
      return
    case 36:
      onEnterPressEvent?()
      return
    case 126:
      onArrowUpEvent?()
      return
    case 125:
      onArrowDownEvent?()
      return
    default:
      super.keyDown(with: event)
    }
  }

  override func layout() {
    super.layout()
    if let textContainer = textContainer {
      textContainer.textView?.drawsBackground = false
    }
    frame.size.height = 20
  }

  override var intrinsicContentSize: NSSize {
    let width = super.intrinsicContentSize.width
    let height = 20.0
    return NSSize(width: width, height: height)
  }

  // see https://blog.kulman.sk/making-copy-paste-work-with-nstextfield/
  // about copy/pasting/undo/redo inside the NSTextView
//  override func performKeyEquivalent(with event: NSEvent) -> Bool {
//    print("performKeyEquivalent: \(event)")
//    return true
//  }

//  example
//  final class EditableNSTextField: NSTextField {
//
//      private let commandKey = NSEvent.ModifierFlags.command.rawValue
//      private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
//
//      override func performKeyEquivalent(with event: NSEvent) -> Bool {
//          if event.type == NSEvent.EventType.keyDown {
//              if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
//                  switch event.charactersIgnoringModifiers! {
//                  case "x":
//                      if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
//                  case "c":
//                      if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
//                  case "v":
//                      if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
//                  case "z":
//                      if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
//                  case "a":
//                      if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
//                  default:
//                      break
//                  }
//              } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
//                  if event.charactersIgnoringModifiers == "Z" {
//                      if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
//                  }
//              }
//          }
//          return super.performKeyEquivalent(with: event)
//      }
//  }
}
