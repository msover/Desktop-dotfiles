import Quickshell
import Quickshell.Io
import Quickshell.Wayland._WlrLayerShell
import QtQuick
import Qt.labs.settings 1.0

Scope {
    id: wallpaperManager

    property color wallpaperTopColor: "#182238"
    property color wallpaperBottomColor: "#0d1119"

    readonly property string homeDirectory: String(Quickshell.env("HOME") || "")
    readonly property string overrideWallpaper: String(Quickshell.env("QS_WALLPAPER") || "")
    property string wallpaperDirectory: wallpaperState.wallpaperDirectory
    property string selectedWallpaper: overrideWallpaper.length ? overrideWallpaper : wallpaperState.selectedWallpaper
    property var wallpapers: []
    property var scanLines: []

    Settings {
        id: wallpaperState
        fileName: Quickshell.statePath("wallpaper.ini")
        category: "wallpaper"

        property string selectedWallpaper: ""
        property string wallpaperDirectory: ""
    }

    function directoryOf(path) {
        var normalized = String(path || "")
        var lastSlash = normalized.lastIndexOf("/")
        return lastSlash > 0 ? normalized.substring(0, lastSlash) : ""
    }

    function defaultDirectories() {
        if (!homeDirectory.length) {
            return []
        }

        return [
            homeDirectory + "/Pictures/Wallpapers",
            homeDirectory + "/Pictures/wallpapers",
            homeDirectory + "/wallpapers"
        ]
    }

    function uniqueNonEmpty(values) {
        var unique = []

        for (var i = 0; i < values.length; i++) {
            var value = String(values[i] || "")
            if (!value.length || unique.indexOf(value) !== -1) {
                continue
            }

            unique.push(value)
        }

        return unique
    }

    readonly property var directoryCandidates: uniqueNonEmpty(
        [
            directoryOf(overrideWallpaper),
            directoryOf(selectedWallpaper),
            wallpaperState.wallpaperDirectory
        ].concat(defaultDirectories())
    )

    function shellQuote(value) {
        return "'" + String(value).split("'").join("'\"'\"'") + "'"
    }

    function toFileUrl(path) {
        var normalized = String(path || "")
        if (!normalized.length) {
            return ""
        }

        return "file://" + normalized.split("/").map(encodeURIComponent).join("/")
    }

    readonly property string wallpaperSource: toFileUrl(selectedWallpaper)

    function buildScanCommand() {
        if (!directoryCandidates.length) {
            return "exit 0\n"
        }

        var script = ""
        script += "set -eu\n"
        script += "for dir in"

        for (var i = 0; i < directoryCandidates.length; i++) {
            script += " " + shellQuote(directoryCandidates[i])
        }

        script += "; do\n"
        script += "  if [ -d \"$dir\" ]; then\n"
        script += "    printf 'DIR\\t%s\\n' \"$dir\"\n"
        script += "    find \"$dir\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \\) | sort\n"
        script += "    exit 0\n"
        script += "  fi\n"
        script += "done\n"
        return script
    }

    function persistSelection(path) {
        selectedWallpaper = String(path || "")

        if (overrideWallpaper.length) {
            return
        }

        if (wallpaperState.selectedWallpaper !== selectedWallpaper) {
            wallpaperState.selectedWallpaper = selectedWallpaper
            wallpaperState.sync()
        }
    }

    function applyScan(lines) {
        var files = []
        var resolvedDirectory = ""

        for (var i = 0; i < lines.length; i++) {
            var line = String(lines[i] || "")
            if (!line.length) {
                continue
            }

            if (line.indexOf("DIR\t") === 0) {
                resolvedDirectory = line.substring(4)
                continue
            }

            files.push(line)
        }

        wallpapers = files

        if (resolvedDirectory.length) {
            wallpaperDirectory = resolvedDirectory

            if (wallpaperState.wallpaperDirectory !== resolvedDirectory) {
                wallpaperState.wallpaperDirectory = resolvedDirectory
                wallpaperState.sync()
            }
        }

        if (overrideWallpaper.length) {
            selectedWallpaper = overrideWallpaper
            return
        }

        if (selectedWallpaper.length && files.indexOf(selectedWallpaper) !== -1) {
            return
        }

        if (wallpaperState.selectedWallpaper.length && files.indexOf(wallpaperState.selectedWallpaper) !== -1) {
            selectedWallpaper = wallpaperState.selectedWallpaper
            return
        }

        if (files.length) {
            persistSelection(files[0])
        }
    }

    function cycle(step) {
        if (overrideWallpaper.length || !wallpapers.length) {
            return
        }

        var currentIndex = wallpapers.indexOf(selectedWallpaper)
        if (currentIndex < 0) {
            currentIndex = 0
        }

        var nextIndex = (currentIndex + step) % wallpapers.length
        if (nextIndex < 0) {
            nextIndex += wallpapers.length
        }

        persistSelection(wallpapers[nextIndex])
    }

    function rescan() {
        if (wallpaperScanner.running) {
            return
        }

        scanLines = []
        wallpaperScanner.running = true
    }

    Process {
        id: wallpaperScanner
        command: ["bash", "-lc", wallpaperManager.buildScanCommand()]
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                var line = String(data || "").replace(/\r$/, "")
                if (line.length) {
                    wallpaperManager.scanLines = wallpaperManager.scanLines.concat([line])
                }
            }
        }

        onStarted: wallpaperManager.scanLines = []
        onExited: wallpaperManager.applyScan(wallpaperManager.scanLines)
        Component.onCompleted: wallpaperManager.rescan()
    }

    Variants {
        model: Quickshell.screens

        delegate: WlrLayershell {
            required property var modelData

            screen: modelData
            layer: WlrLayer.Background
            namespace: "quickshell-wallpaper"
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            color: wallpaperManager.wallpaperBottomColor
            implicitWidth: modelData.width
            implicitHeight: modelData.height

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: wallpaperManager.wallpaperTopColor
                    }

                    GradientStop {
                        position: 1.0
                        color: wallpaperManager.wallpaperBottomColor
                    }
                }
            }

            Image {
                anchors.fill: parent
                source: wallpaperManager.wallpaperSource
                asynchronous: true
                cache: true
                smooth: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: Math.max(parent.width, 1)
                sourceSize.height: Math.max(parent.height, 1)
                opacity: status === Image.Ready ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#14000000"
            }
        }
    }
}
