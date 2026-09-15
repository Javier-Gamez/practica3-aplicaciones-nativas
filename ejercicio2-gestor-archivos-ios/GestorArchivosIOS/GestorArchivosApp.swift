import SwiftUI

@main
struct GestorArchivosApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(nil) // follow the system light/dark setting
        }
    }
}
