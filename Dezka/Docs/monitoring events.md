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
