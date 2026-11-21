import SwiftUI

@main
struct SensorLiveApp: App {
    @State private var hub = SensorHub()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(hub)
        }
    }
}
