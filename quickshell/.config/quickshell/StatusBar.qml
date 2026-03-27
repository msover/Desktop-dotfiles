import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: statusBar
    property var wallpaperManager
    property string textFont: "JetBrainsMono Nerd Font"
    property string iconFont: textFont
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        left: 9
        right: 9
        top: 0
    }

    implicitHeight: 42
    color: "transparent"
    focusable: false

    Rectangle {
        anchors.fill: parent
        color: statusBar.surfaceColor
        border.color: statusBar.accentColor
        border.width: 3
        radius: 16
    }

    Text {
        id: logo
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        text: ""
        color: statusBar.accentColor
        font.pixelSize: 22
        font.family: statusBar.iconFont
        verticalAlignment: Text.AlignVCenter

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: mouse => {
                if (!statusBar.wallpaperManager) {
                    return
                }

                if (mouse.button === Qt.RightButton) {
                    statusBar.wallpaperManager.rescan()
                } else {
                    statusBar.wallpaperManager.cycle(1)
                }
            }

            onEntered: parent.opacity = 0.75
            onExited: parent.opacity = 1.0
        }
    }

    Rectangle {
        id: logoSeparator
        anchors.left: logo.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 10
        color: statusBar.mutedColor
    }

    Item {
        id: mediaControlsContainer
        anchors.left: logoSeparator.right
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 130
        height: parent.height

        property var currentPlayer: Mpris.players.values[0] || null

        Row {
            spacing: 24
            anchors.centerIn: parent
            visible: mediaControlsContainer.currentPlayer !== null

            Text {
                text: "󰒮"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                opacity: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious ? 1.0 : 0.5

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious) {
                            mediaControlsContainer.currentPlayer.previous()
                        }
                    }

                    onEntered: {
                        if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious) {
                            parent.opacity = 0.8
                        }
                    }

                    onExited: parent.opacity = mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoPrevious ? 1.0 : 0.5
                }
            }

            Text {
                text: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (!mediaControlsContainer.currentPlayer) {
                            return
                        }

                        if (mediaControlsContainer.currentPlayer.playbackState === MprisPlaybackState.Playing) {
                            if (mediaControlsContainer.currentPlayer.canPause) {
                                mediaControlsContainer.currentPlayer.pause()
                            }
                        } else if (mediaControlsContainer.currentPlayer.canPlay) {
                            mediaControlsContainer.currentPlayer.play()
                        }
                    }

                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                }
            }

            Text {
                text: "󰒭"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                opacity: mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext ? 1.0 : 0.5

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext) {
                            mediaControlsContainer.currentPlayer.next()
                        }
                    }

                    onEntered: {
                        if (mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext) {
                            parent.opacity = 0.8
                        }
                    }

                    onExited: parent.opacity = mediaControlsContainer.currentPlayer && mediaControlsContainer.currentPlayer.canGoNext ? 1.0 : 0.5
                }
            }
        }
    }

    Rectangle {
        id: mediaControlsSeparator
        anchors.left: mediaControlsContainer.right
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 10
        color: statusBar.mutedColor
        visible: mediaControlsContainer.currentPlayer !== null
    }

    Item {
        id: mediaInfo
        anchors.left: mediaControlsSeparator.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(parent.width / 3 - 20, 260)
        height: parent.height

        property var currentPlayer: Mpris.players.values[0] || null

        Row {
            spacing: 10
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 10

            Text {
                text: "󰎈"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: parent.width - 40
                text: {
                    if (mediaInfo.currentPlayer && mediaInfo.currentPlayer.metadata) {
                        var artist = mediaInfo.currentPlayer.metadata["xesam:artist"] || ""
                        var title = mediaInfo.currentPlayer.metadata["xesam:title"] || ""

                        if (Array.isArray(artist)) {
                            artist = artist.join(", ")
                        }

                        if (artist && title) {
                            return artist + " - " + title
                        }

                        return title || artist || "No media playing"
                    }

                    return "No media playing"
                }
                color: statusBar.textColor
                font.pixelSize: 16
                font.family: statusBar.textFont
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    Row {
        id: workspaces
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: 10

            Rectangle {
                width: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1 ? 60 : 20
                height: 20
                radius: 10
                color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === index + 1 ? statusBar.accentColor : statusBar.mutedColor

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace", (index + 1).toString())
                }
            }
        }
    }

    Item {
        id: time
        anchors.right: parent.right
        anchors.rightMargin: 125
        anchors.verticalCenter: parent.verticalCenter

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                timeText.text = Qt.formatDateTime(new Date(), "ddd dd/MM")
                timeHour.text = Qt.formatDateTime(new Date(), "h:mma")
            }
        }

        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "󰥔"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: timeHour
                text: Qt.formatDateTime(new Date(), "h:mma")
                color: statusBar.textColor
                font.pixelSize: 16
                font.family: statusBar.textFont
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 2
                height: statusBar.height - 10
                color: statusBar.mutedColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: timeText
                text: Qt.formatDateTime(new Date(), "ddd dd/MM")
                color: statusBar.textColor
                font.pixelSize: 16
                font.family: statusBar.textFont
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 110
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 10
        color: statusBar.mutedColor
    }

    Item {
        id: volume
        anchors.right: parent.right
        anchors.rightMargin: 22.5
        anchors.verticalCenter: parent.verticalCenter
        width: 80
        height: parent.height

        property string volumeLevel: ""
        property bool muted: false
        property bool isToggling: false

        Process {
            id: volumeProcess
            running: true
            command: ["bash", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\" | while read -r line; do pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1; done"]
            stdout: SplitParser {
                onRead: data => {
                    var vol = data.trim().replace("%", "")
                    if (vol) {
                        volume.volumeLevel = vol
                    }
                }
            }
        }

        Process {
            id: initialVolume
            command: ["bash", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1"]
            stdout: SplitParser {
                onRead: data => {
                    var vol = data.trim().replace("%", "")
                    if (vol) {
                        volume.volumeLevel = vol
                    }
                }
            }
        }

        Process {
            id: muteStatus
            command: ["bash", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -oE 'yes|no'"]
            stdout: SplitParser {
                onRead: data => {
                    volume.muted = data.trim() === "yes"
                    if (volume.isToggling) {
                        volume.isToggling = false
                    }
                }
            }
        }

        Component.onCompleted: {
            initialVolume.running = true
            muteStatus.running = true
        }

        Row {
            spacing: 5
            anchors.centerIn: parent
            clip: false

            Text {
                id: volumeIcon
                width: 28
                height: 28
                text: volume.muted ? "󰖁" : "󰕾"
                color: statusBar.accentColor
                font.pixelSize: 20
                font.family: statusBar.iconFont
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        if (volume.isToggling) {
                            return
                        }

                        volume.isToggling = true
                        muteToggle.command = ["bash", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
                        muteToggle.running = true
                        volume.muted = !volume.muted
                        muteStatusRefresh.start()
                    }

                    onEntered: parent.opacity = 0.6
                    onExited: parent.opacity = 1.0

                    Timer {
                        id: muteStatusRefresh
                        interval: 150
                        repeat: false

                        onTriggered: {
                            muteStatus.running = true
                            volume.isToggling = false
                        }
                    }

                    Process {
                        id: muteToggle
                        command: []
                    }
                }
            }

            Text {
                id: volumeText
                text: volume.volumeLevel ? volume.volumeLevel + "%" : "--"
                color: statusBar.textColor
                font.pixelSize: 16
                font.family: statusBar.textFont
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
