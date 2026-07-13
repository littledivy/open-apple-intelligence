import SwiftUI

@main
struct ChatDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 560, minHeight: 480)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 720, height: 620)
    }
}
