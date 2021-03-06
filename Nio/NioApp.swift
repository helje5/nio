import SwiftUI
import NioKit

@main
struct NioApp: App {
    @StateObject var accountStore = AccountStore()

    @AppStorage("accentColor") var accentColor: Color = .purple

    var body: some Scene {
        WindowGroup {
          #if os(macOS)
            RootView()
                .environmentObject(accountStore)
                .accentColor(accentColor)
                .frame(minWidth: 600, idealWidth: 720, minHeight: 320)
                .presentedWindowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
          #else
            RootView()
                .environmentObject(accountStore)
                .accentColor(accentColor)
          #endif
        }
    }
}
