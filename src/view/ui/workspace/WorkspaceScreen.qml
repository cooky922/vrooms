import QtQuick
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: workspaceScreen

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "VroomS!"
                font.pixelSize: 24
                font.family: appTheme.rokkittFontName
                color: "#333333"
            }

            Components.PrimaryButton {
                text: "Go to Login"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

            Components.SecondaryButton {
                text: "Go to Login"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

            Components.FloatingButton {
                text: "Go to Login"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

        }

    }
}