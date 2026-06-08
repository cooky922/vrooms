import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string entityName: "Unit"
    property var oldData: ({})

    signal deleteConfirmed()

    anchors.centerIn: Overlay.overlay
    width: 320
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Overlay.modal: Rectangle { color: "#40000000" }

    background: Rectangle {
        color: "#FAFAFA"
        radius: 16
    }

    contentItem: ColumnLayout {
        spacing: 16

        Image {
            source: "../../../../assets/images/delete-mascot.png"
            sourceSize: Qt.size(80, 80)
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Delete " + root.entityName
                font { pixelSize: 15; bold: true; family: appTheme.rethinkSansFontName }
                color: "#1A1A1A"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "You are about to delete this " + root.entityName.toLowerCase() + ". Are you sure you want to proceed?"
                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                color: "#666666"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: 10
                color: cancelHover.hovered ? "#C8CDD4" : "#D4D9DF"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                    color: "#333"
                }
                HoverHandler { id: cancelHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.close() }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: 10
                color: confirmHover.hovered ? "#C62828" : "#E53935"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "Delete"
                    font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                    color: "white"
                }
                HoverHandler { id: confirmHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        root.deleteConfirmed()
                        root.close()
                    }
                }
            }
        }
    }
}