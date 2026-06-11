import Quickshell
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland
import QtQuick

Variants {
    id: workspaceBarVariants

    property string textFont: "JetBrainsMono Nerd Font"
    property color surfaceColor: "#1e1e2e"
    property color accentColor: "#cba6f7"
    property color occupiedColor: "#8a6bb3" // Dark purple for has-windows but unfocused
    property color mutedColor: "#45475a"
    property color textColor: "#ffffff"

    model: Quickshell.screens

    delegate: WlrLayershell {
        id: barWindow
        required property var modelData

        screen: modelData
        layer: WlrLayer.Top
        namespace: "workspace-bar"
        exclusiveZone: 0
        focusable: false
        color: "transparent"
        
        implicitWidth: layoutRow.width + 32
        implicitHeight: 40

        property bool isLeftMonitor: modelData.name === "DP-4"
        property bool isRightMonitor: modelData.name === "DP-5"

        // Put both toolbars on the bottom
        anchors {
            bottom: true
        }
        
        // Small margin so the rounded curve is fully visible
        margins {
            bottom: 8
        }

        visible: isLeftMonitor || isRightMonitor

        property bool isVisible: false
        
        Connections {
            target: Hyprland
            function onFocusedWorkspaceChanged() {
                if (Hyprland.focusedWorkspace) {
                    var wsId = Hyprland.focusedWorkspace.id;
                    var isOnThisMonitor = (barWindow.isRightMonitor && wsId >= 1 && wsId <= 5) || 
                                          (barWindow.isLeftMonitor && wsId >= 6 && wsId <= 10);
                    if (isOnThisMonitor) {
                        barWindow.isVisible = true;
                        hideTimer.restart();
                    }
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
                color: Qt.alpha(workspaceBarVariants.surfaceColor, 0.88)
                border.color: Qt.alpha(workspaceBarVariants.accentColor, 0.82)
                border.width: 2
            }

            Row {
                id: layoutRow
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: 5
                    delegate: Item {
                        id: wsItem
                        width: 24
                        height: 24

                        property int visualNumber: index + 1
                        property int workspaceId: barWindow.isRightMonitor ? visualNumber : visualNumber + 5

                        property bool isActiveOnMonitor: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === workspaceId
                        property bool hasWindows: false
                        
                        Timer {
                            interval: 100
                            running: true
                            repeat: true
                            onTriggered: {
                                var windows = false;
                                if (Hyprland.toplevels && Hyprland.toplevels.values) {
                                    for (var i = 0; i < Hyprland.toplevels.values.length; ++i) {
                                        var tl = Hyprland.toplevels.values[i];
                                        if (tl && tl.workspace && tl.workspace.id === wsItem.workspaceId) {
                                            windows = true;
                                            break;
                                        }
                                    }
                                }
                                wsItem.hasWindows = windows;
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            
                            color: {
                                if (wsItem.isActiveOnMonitor) return workspaceBarVariants.accentColor;
                                if (wsItem.hasWindows) return workspaceBarVariants.occupiedColor;
                                return workspaceBarVariants.mutedColor;
                            }

                            // Smooth color transition
                            Behavior on color { ColorAnimation { duration: 250 } }

                            // Pop out the active workspace slightly
                            scale: wsItem.isActiveOnMonitor ? 1.15 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: wsItem.visualNumber
                                // Dark text on light background (active), light text otherwise
								color: workspaceBarVariants.surfaceColor
                                font.family: workspaceBarVariants.textFont
                                font.bold: true
                                font.pixelSize: 13

                                Behavior on color { ColorAnimation { duration: 250 } }
                            }
                        }
                    }
                }
            }
        }
        
        Component.onCompleted: {
            if (Hyprland.focusedWorkspace) {
                var wsId = Hyprland.focusedWorkspace.id;
                var isOnThisMonitor = (barWindow.isRightMonitor && wsId >= 1 && wsId <= 5) || 
                                      (barWindow.isLeftMonitor && wsId >= 6 && wsId <= 10);
                if (isOnThisMonitor) {
                    barWindow.isVisible = true;
                    hideTimer.start();
                }
            }
        }
    }
}
