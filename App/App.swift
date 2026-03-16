import SwiftUI

/// Sets activation policy so the menu bar icon is visible. .accessory = menu bar only (no Dock); .regular = Dock + menu bar.
private final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Use .accessory for menu-bar-only (status item shows). Use .regular if you want Dock icon too.
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct App: SwiftUI.App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var serverController = ServerController()
    @AppStorage("isEnabled") private var isEnabled = true
    @State private var isMenuPresented = false

    var body: some Scene {
        MenuBarExtra("iMCP", image: #"MenuIcon-\#(isEnabled ? "On" : "Off")"#) {
            ContentView(
                serverManager: serverController,
                isEnabled: $isEnabled,
                isMenuPresented: $isMenuPresented
            )
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(serverController: serverController)
        }

        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
