import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage
import Quickshell
import Quickshell.Widgets

Window {
    id: appLauncher
    title: "App Launcher"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    width: 560
    height: 360

    property string textFont: "JetBrainsMono Nerd Font"
    property string iconFont: textFont
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"
    property real cornerRadius: 10
    property string query: ""

    function resetState() {
        query = "";
        input.text = "";
        list.currentIndex = filtered.values.length > 0 ? 0 : -1;
    }

    function openLauncher() {
        resetState();
        visible = true;
        Qt.callLater(() => input.forceActiveFocus());
    }

    function closeLauncher() {
        visible = false;
        resetState();
    }

    function launchSelected() {
        if (list.currentItem && list.currentItem.modelData) {
            list.currentItem.modelData.execute();
            closeLauncher();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: appLauncher.cornerRadius
        color: Qt.alpha(appLauncher.surfaceColor, 0.96)
        border.width: 3
        border.color: appLauncher.accentColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                implicitHeight: input.implicitHeight + 8
                radius: appLauncher.cornerRadius
                color: Qt.alpha(appLauncher.mutedColor, 0.96)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 8

                    IconImage {
                        Layout.leftMargin: 10
                        source: Quickshell.iconPath("nix-snowflake", true)
                        Layout.preferredWidth: 25
                        Layout.preferredHeight: 25
                    }

                    TextField {
                        id: input
                        Layout.fillWidth: true
                        placeholderText: "Run…"
                        placeholderTextColor: appLauncher.textColor
                        font.family: appLauncher.textFont
                        font.pixelSize: 18
                        color: appLauncher.textColor
                        selectionColor: appLauncher.accentColor
                        selectedTextColor: appLauncher.surfaceColor
                        focus: appLauncher.visible

                        padding: 15

                        onTextChanged: {
                            appLauncher.query = text;
                            list.currentIndex = filtered.values.length > 0 ? 0 : -1;
                        }

                        background: Rectangle {
                            border.width: 0
                            color: "transparent"
                        }

                        Keys.onEscapePressed: appLauncher.closeLauncher()
                        Keys.onPressed: event => {
                            const ctrl = event.modifiers & Qt.ControlModifier;
                            if (event.key == Qt.Key_Up || event.key == Qt.Key_P && ctrl) {
                                event.accepted = true;
                                if (list.currentIndex > 0)
                                    list.currentIndex--;
                            } else if (event.key == Qt.Key_Down || event.key == Qt.Key_N && ctrl) {
                                event.accepted = true;
                                if (list.currentIndex < list.count - 1)
                                    list.currentIndex++;
                            } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key)) {
                                event.accepted = true;
                                appLauncher.launchSelected();
                            } else if (event.key == Qt.Key_C && ctrl) {
                                event.accepted = true;
                                appLauncher.closeLauncher();
                            }
                        }
                    }
                }
            }

            ScriptModel {
                id: filtered
                values: {
                    const allEntries = [...DesktopEntries.applications.values];
                    const q = appLauncher.query.trim().toLowerCase();

                    if (q === "") {
                        return allEntries;
                    }

                    return allEntries.filter(d => d.name && d.name.toLowerCase().includes(q));
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: filtered.values
                currentIndex: filtered.values.length > 0 ? 0 : -1
                keyNavigationWraps: true
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                highlightRangeMode: ListView.ApplyRange
                highlightMoveDuration: 80
                highlight: Rectangle {
                    radius: appLauncher.cornerRadius
                    color: appLauncher.accentColor
                    opacity: 0.2
                }

                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 42

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: list.currentIndex = entry.index
                        onDoubleClicked: appLauncher.launchSelected()
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            width: 22
                            height: 22
                        }

                        Text {
                            id: label
                            width: parent.width - 34
                            color: appLauncher.textColor
                            text: modelData.name
                            font.family: appLauncher.textFont
                            font.pixelSize: 15
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Keys.onEscapePressed: appLauncher.closeLauncher()
                Keys.onReturnPressed: appLauncher.launchSelected()
            }
        }
    }
}
