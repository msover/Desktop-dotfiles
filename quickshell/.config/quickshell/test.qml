import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    Component.onCompleted: {
        for (var prop in Hyprland) {
            console.log("Hyprland." + prop + " = " + typeof Hyprland[prop]);
        }
        Qt.quit()
    }
}
