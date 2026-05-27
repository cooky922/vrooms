import QtQuick
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: workspaceScreen

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"

        Text {
            text: "VroomS!"
            anchors.centerIn: parent
            font.pixelSize: 24
            font.family: appTheme.rokkittFontName
            color: "#333333"
        }
    }
}