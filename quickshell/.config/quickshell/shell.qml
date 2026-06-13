import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    readonly property string textFont: String(Quickshell.env("QS_TEXT_FONT") || "JetBrainsMono Nerd Font")
    readonly property string iconFont: String(Quickshell.env("QS_ICON_FONT") || textFont)
    readonly property color surfaceColor: "#1e1e2e"
    readonly property color accentColor: "#cba6f7"
    readonly property color mutedColor: "#45475a"
    readonly property color textColor: "#ffffff"
    readonly property color wallpaperTopColor: "#182238"
    readonly property color wallpaperBottomColor: "#0d1119"

    WallpaperManager {
        id: wallpaperManager
        wallpaperTopColor: root.wallpaperTopColor
        wallpaperBottomColor: root.wallpaperBottomColor
    }

    AppLauncher {
        id: appLauncher
        textFont: root.textFont
        iconFont: root.iconFont
        surfaceColor: root.surfaceColor
        accentColor: root.accentColor
        mutedColor: root.mutedColor
        textColor: root.textColor
    }

    IpcHandler {
        target: "app-launcher"

        function open(monitorName: string): void {
            appLauncher.openLauncher(monitorName);
        }
    }

    ClockWidget {
        textFont: root.textFont
        iconFont: root.iconFont
        surfaceColor: root.surfaceColor
        accentColor: root.accentColor
        mutedColor: root.mutedColor
        textColor: root.textColor
    }

    WallpaperWidget {
        wallpaperManager: wallpaperManager
        textFont: root.textFont
        iconFont: root.iconFont
        surfaceColor: root.surfaceColor
        accentColor: root.accentColor
        mutedColor: root.mutedColor
        textColor: root.textColor
    }

    WorkspaceBar {
        textFont: root.textFont
        surfaceColor: root.surfaceColor
        accentColor: root.accentColor
        mutedColor: root.mutedColor
        textColor: root.textColor
    }
}
