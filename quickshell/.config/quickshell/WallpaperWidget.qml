import Quickshell
import Quickshell.Wayland._WlrLayerShell
import QtQuick

Variants {
    id: wallpaperWidget

    property var wallpaperManager
    property string textFont: "JetBrainsMono Nerd Font"
    property string iconFont: textFont
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"

    model: Quickshell.screens

    delegate: WlrLayershell {
        id: wallpaperWindow

        required property var modelData

        readonly property bool hasManager: wallpaperWidget.wallpaperManager !== null && wallpaperWidget.wallpaperManager !== undefined
        readonly property string selectedWallpaper: hasManager ? wallpaperWidget.wallpaperManager.selectedWallpaper : ""
        readonly property var wallpapers: hasManager ? wallpaperWidget.wallpaperManager.wallpapers : []
        readonly property int wallpaperCount: wallpapers ? wallpapers.length : 0
        readonly property int wallpaperIndex: wallpaperCount > 0 ? wallpapers.indexOf(selectedWallpaper) : -1
        readonly property bool hasOverride: hasManager && wallpaperWidget.wallpaperManager.overrideWallpaper.length > 0
        readonly property bool canCycle: hasManager && !hasOverride && wallpaperCount > 1

        function basename(path) {
            var normalized = String(path || "")
            while (normalized.length > 1 && normalized.charAt(normalized.length - 1) === "/") {
                normalized = normalized.substring(0, normalized.length - 1)
            }

            var lastSlash = normalized.lastIndexOf("/")
            return lastSlash >= 0 ? normalized.substring(lastSlash + 1) : normalized
        }

        function statusText() {
            if (hasOverride) {
                return "Pinned by QS_WALLPAPER"
            }

            if (!wallpaperCount) {
                return "No wallpapers found"
            }

            if (wallpaperIndex >= 0) {
                return (wallpaperIndex + 1) + " / " + wallpaperCount
            }

            return wallpaperCount + " wallpapers"
        }

        screen: modelData
        layer: WlrLayer.Bottom
        namespace: "quickshell-wallpaper-widget"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        focusable: false
        color: "transparent"
        implicitWidth: Math.max(260, Math.min(320, modelData.width - 48))
        implicitHeight: 118

        anchors {
            left: true
            top: true
        }

        margins {
            left: 24
            top: 186
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Qt.alpha(wallpaperWidget.surfaceColor, 0.88)
            border.color: Qt.alpha(wallpaperWidget.accentColor, 0.82)
            border.width: 2
        }

        Item {
            anchors.fill: parent
            anchors.margins: 14

            Column {
                anchors.fill: parent
                spacing: 6

                Row {
                    width: parent.width
                    height: 24
                    spacing: 8

                    Text {
                        width: 24
                        height: 24
                        text: "󰸉"
                        color: wallpaperWidget.accentColor
                        font.pixelSize: 20
                        font.family: wallpaperWidget.iconFont
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: parent.width - 32
                        text: "Wallpaper"
                        color: wallpaperWidget.textColor
                        font.pixelSize: 15
                        font.family: wallpaperWidget.textFont
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    width: parent.width
                    height: 20
                    text: wallpaperWindow.basename(wallpaperWindow.selectedWallpaper) || "No wallpaper selected"
                    color: wallpaperWidget.textColor
                    font.pixelSize: 15
                    font.family: wallpaperWidget.textFont
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Item {
                    width: parent.width
                    height: 34

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 94
                        text: wallpaperWindow.statusText()
                        color: Qt.alpha(wallpaperWidget.textColor, 0.68)
                        font.pixelSize: 13
                        font.family: wallpaperWidget.textFont
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Rectangle {
                            id: previousButton

                            width: 38
                            height: 34
                            radius: 9
                            enabled: wallpaperWindow.canCycle
                            color: previousMouse.containsMouse && enabled ? Qt.alpha(wallpaperWidget.accentColor, 0.30) : Qt.alpha(wallpaperWidget.mutedColor, 0.74)
                            border.color: enabled ? Qt.alpha(wallpaperWidget.accentColor, 0.52) : Qt.alpha(wallpaperWidget.mutedColor, 0.42)
                            opacity: enabled ? 1.0 : 0.42

                            Text {
                                anchors.centerIn: parent
                                text: "󰒮"
                                color: wallpaperWidget.textColor
                                font.pixelSize: 18
                                font.family: wallpaperWidget.iconFont
                            }

                            MouseArea {
                                id: previousMouse

                                anchors.fill: parent
                                enabled: previousButton.enabled
                                hoverEnabled: true
                                cursorShape: previousButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: wallpaperWidget.wallpaperManager.cycle(-1)
                            }
                        }

                        Rectangle {
                            id: nextButton

                            width: 38
                            height: 34
                            radius: 9
                            enabled: wallpaperWindow.canCycle
                            color: nextMouse.containsMouse && enabled ? Qt.alpha(wallpaperWidget.accentColor, 0.30) : Qt.alpha(wallpaperWidget.mutedColor, 0.74)
                            border.color: enabled ? Qt.alpha(wallpaperWidget.accentColor, 0.52) : Qt.alpha(wallpaperWidget.mutedColor, 0.42)
                            opacity: enabled ? 1.0 : 0.42

                            Text {
                                anchors.centerIn: parent
                                text: "󰒭"
                                color: wallpaperWidget.textColor
                                font.pixelSize: 18
                                font.family: wallpaperWidget.iconFont
                            }

                            MouseArea {
                                id: nextMouse

                                anchors.fill: parent
                                enabled: nextButton.enabled
                                hoverEnabled: true
                                cursorShape: nextButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: wallpaperWidget.wallpaperManager.cycle(1)
                            }
                        }
                    }
                }
            }
        }
    }
}
