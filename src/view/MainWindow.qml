import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: app
    width: 800
    minimumWidth: 800
    height: 500
    minimumHeight: 500

    visible: true
    title: "VroomS - Motor Rental Management System"

    Rectangle {
        anchors.fill: parent
        color: "#f0f0f0"

        Text {
            text: "VroomS!"
            anchors.centerIn: parent
            font.pixelSize: 24
            color: "#333333"
        }
    }
}