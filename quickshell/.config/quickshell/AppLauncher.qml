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
    property real cornerRadius: 12
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
        anchors.margins: 0
        radius: appLauncher.cornerRadius
        color: Qt.alpha(appLauncher.surfaceColor, 0.98)
        border.width: 1
        border.color: Qt.alpha(appLauncher.accentColor, 0.4)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Search Bar Area
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 8
                color: Qt.alpha(appLauncher.mutedColor, 0.3)
                border.width: 1
                border.color: input.activeFocus ? Qt.alpha(appLauncher.accentColor, 0.8) : Qt.alpha(appLauncher.mutedColor, 0.5)

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 12

                    IconImage {
                        source: Quickshell.iconPath("nix-snowflake", true)
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignVCenter
                        opacity: input.activeFocus ? 1.0 : 0.7
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    TextField {
                        id: input
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "Search apps..."
                        placeholderTextColor: Qt.alpha(appLauncher.textColor, 0.4)
                        font.family: appLauncher.textFont
                        font.pixelSize: 16
                        color: appLauncher.textColor
                        selectionColor: Qt.alpha(appLauncher.accentColor, 0.5)
                        selectedTextColor: appLauncher.textColor
                        focus: appLauncher.visible
                        verticalAlignment: TextInput.AlignVCenter

                        background: Item {} // Transparent background

                        onTextChanged: {
                            appLauncher.query = text;
                            list.currentIndex = filtered.values.length > 0 ? 0 : -1;
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

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.alpha(appLauncher.mutedColor, 0.3)
            }

            ScriptModel {
                id: filtered
                values: {
                    const allEntries = [...DesktopEntries.applications.values];
                    const q = appLauncher.query.trim().toLowerCase();

                    // Sort entries alphabetically
                    let sortedEntries = allEntries.sort((a, b) => {
                        const nameA = a.name || "";
                        const nameB = b.name || "";
                        return nameA.localeCompare(nameB);
                    });

                    if (q === "") {
                        return sortedEntries;
                    }

                    return sortedEntries.filter(d => d.name && d.name.toLowerCase().includes(q));
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: filtered
                currentIndex: filtered.values.length > 0 ? 0 : -1
                keyNavigationWraps: true
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                highlightRangeMode: ListView.ApplyRange
                highlightMoveDuration: 150
                boundsBehavior: Flickable.StopAtBounds

                highlight: Item {
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        radius: 6
                        color: Qt.alpha(appLauncher.accentColor, 0.15)
                        
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            width: 3
                            radius: 1.5
                            color: appLauncher.accentColor
                        }
                    }
                }

                delegate: Item {
                    id: entry
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 48

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: list.currentIndex = entry.index
                        onDoubleClicked: appLauncher.launchSelected()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16

                        IconImage {
                            source: Quickshell.iconPath(modelData.icon, true)
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            color: appLauncher.textColor
                            text: modelData.name
                            font.family: appLauncher.textFont
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                    }
                }

                Keys.onEscapePressed: appLauncher.closeLauncher()
                Keys.onReturnPressed: appLauncher.launchSelected()
            }
        }
    }
}