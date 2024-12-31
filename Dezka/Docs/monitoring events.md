https://chatgpt.com/share/67737afe-b2e4-8011-a808-f801bac25a45


```swift
 import SwiftUI

struct ContentView: View {
    @State private var isCmdPressed = false
    @State private var isGPressed = false

    var body: some View {
        Text("Press Cmd+G, release G, then Cmd")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
                    handleKeyEvent(event: event)
                    return event
                }
            }
    }

    private func handleKeyEvent(event: NSEvent) {
        switch event.type {
        case .keyDown:
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "g" {
                isCmdPressed = true
                isGPressed = true
                print("Cmd+G pressed")
            }
        case .keyUp:
            if event.charactersIgnoringModifiers == "g" {
                isGPressed = false
                print("G released")
            }
            if event.keyCode == 55 { // Cmd key's keyCode
                if !isGPressed {
                    isCmdPressed = false
                    print("Cmd released after G")
                }
            }
        default:
            break
        }
    }
}
```

and using a nstextview:

```swift
import SwiftUI

class CustomTextView: NSTextView {
    private var isCmdPressed = false
    private var isGPressed = false

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "g" {
            isCmdPressed = true
            isGPressed = true
            print("Cmd+G pressed")
            return // Prevent default behavior if needed
        }
        super.keyDown(with: event) // Forward to superclass
    }

    override func keyUp(with event: NSEvent) {
        if event.charactersIgnoringModifiers == "g" {
            isGPressed = false
            print("G released")
        }
        super.keyUp(with: event) // Forward to superclass
    }

    override func flagsChanged(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            if !isCmdPressed {
                isCmdPressed = true
                print("Cmd pressed")
            }
        } else {
            if isCmdPressed {
                isCmdPressed = false
                print("Cmd released")
            }
        }
        super.flagsChanged(with: event) // Forward to superclass
    }
}

struct CustomTextViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = CustomTextView()

        textView.isRichText = false
        textView.isEditable = true
        textView.isSelectable = true

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // Update view if needed
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Custom NSTextView Example with Cmd+G Detection")
                .font(.headline)
            CustomTextViewRepresentable()
                .frame(height: 200)
        }
        .padding()
    }
}
```
