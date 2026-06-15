import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Io
import QtQuick

Variants {
    id: clockWidget

    property string textFont: "JetBrainsMono Nerd Font"
    property string iconFont: textFont
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"

    model: Quickshell.screens

    delegate: WlrLayershell {
        id: clockWindow

        required property var modelData

        property string timeValue: ""
        property string dateValue: ""

        function refresh() {
            var now = new Date()
            timeValue = Qt.formatDateTime(now, "HH:mm")
            dateValue = Qt.formatDateTime(now, "ddd, dd MMM")
        }

        screen: modelData
        layer: WlrLayer.Bottom
        namespace: "quickshell-clock-widget"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        focusable: false
        color: "transparent"
        implicitWidth: Math.max(220, Math.min(300, modelData.width - 48))
        implicitHeight: 146

        anchors {
            left: true
            top: true
        }

        margins {
            left: 24
            top: 24
        }

        Process {
            id: calendarProcess
            command: ["morgen"]
        }

        Component.onCompleted: refresh()

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockWindow.refresh()
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Qt.alpha(clockWidget.surfaceColor, 0.88)
            border.color: Qt.alpha(clockWidget.accentColor, 0.82)
            border.width: 2
        }

        Text {
            width: 26
            height: 26
            text: "󰸗"
            color: clockWidget.accentColor
            font.pixelSize: 30
            font.family: clockWidget.iconFont
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 16
            anchors.bottomMargin: 16

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: calendarProcess.running = true
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 4

            Row {
                width: parent.width
                height: 26
                spacing: 10

                Text {
                    width: 26
                    height: 26
                    text: "󰥔"
                    color: clockWidget.accentColor
                    font.pixelSize: 22
                    font.family: clockWidget.iconFont
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: parent.width - 36
                    height: 2
                    radius: 1
                    color: clockWidget.mutedColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                width: parent.width
                height: 60
                text: clockWindow.timeValue
                color: clockWidget.textColor
                font.pixelSize: 52
                font.family: clockWidget.textFont
                font.bold: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: parent.width
                text: clockWindow.dateValue
                color: Qt.alpha(clockWidget.textColor, 0.76)
                font.pixelSize: 16
                font.family: clockWidget.textFont
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
