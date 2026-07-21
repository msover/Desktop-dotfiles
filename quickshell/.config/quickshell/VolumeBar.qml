import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick

Item {
    id: volumeBarRoot

    property string textFont: "JetBrainsMono Nerd Font"
    property string iconFont: textFont
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"

    // Keeps the default sink bound so its volume/mute stay live-updated
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sinkAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property real volumeLevel: sinkAudio ? sinkAudio.volume : 0
    property bool muted: sinkAudio ? sinkAudio.muted : false

    // Pinged whenever the volume level or mute state actually changes
    signal volumeChanged()
    onVolumeLevelChanged: volumeBarRoot.volumeChanged()
    onMutedChanged: volumeBarRoot.volumeChanged()

    Variants {
        id: volumeBarVariants

        model: Quickshell.screens

        delegate: WlrLayershell {
            id: barWindow
            required property var modelData

            screen: modelData
            layer: WlrLayer.Top
            namespace: "volume-bar"
            exclusiveZone: 0
            focusable: false
            color: "transparent"

            implicitWidth: layoutRow.width + 32
            implicitHeight: 40

            property bool isActiveMonitor: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === modelData.name

            // Same spot as the workspace bar: bottom-center
            anchors {
                bottom: true
            }

            // Small margin so the rounded curve is fully visible
            margins {
                bottom: 8
            }

            visible: true

            property bool isVisible: false

            Connections {
                target: volumeBarRoot
                function onVolumeChanged() {
                    if (barWindow.isActiveMonitor) {
                        barWindow.isVisible = true;
                        hideTimer.restart();
                    }
                }
            }

            Timer {
                id: hideTimer
                interval: 900
                onTriggered: barWindow.isVisible = false
            }

            Item {
                anchors.fill: parent

                // Slide up/down animation from bottom
                transform: Translate {
                    y: barWindow.isVisible ? 0 : barWindow.height + 10
                    Behavior on y {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }

                // Completely rounded pill
                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: Qt.alpha(volumeBarRoot.surfaceColor, 0.88)
                    border.color: Qt.alpha(volumeBarRoot.accentColor, 0.82)
                    border.width: 2
                }

                Row {
                    id: layoutRow
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (volumeBarRoot.muted || volumeBarRoot.volumeLevel <= 0) return "󰝟";
                            if (volumeBarRoot.volumeLevel <= 0.33) return "󰕿";
                            if (volumeBarRoot.volumeLevel <= 0.66) return "󰖀";
                            return "󰕾";
                        }
                        color: volumeBarRoot.accentColor
                        font.family: volumeBarRoot.iconFont
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        id: track
                        width: 120
                        height: 8
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: volumeBarRoot.mutedColor

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            width: parent.width * Math.max(0, Math.min(1, volumeBarRoot.volumeLevel))
                            color: volumeBarRoot.muted ? volumeBarRoot.mutedColor : volumeBarRoot.accentColor

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Text {
                        width: 48
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: volumeBarRoot.muted ? "Muted" : Math.round(volumeBarRoot.volumeLevel * 100) + "%"
                        color: volumeBarRoot.textColor
                        font.family: volumeBarRoot.textFont
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
