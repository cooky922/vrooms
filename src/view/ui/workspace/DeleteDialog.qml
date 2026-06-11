import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Popup {
    id: root

    property string entityName: "Unit"
    property var oldData: null

    signal deleteClicked(var data)

    anchors.centerIn: Overlay.overlay
    width: 320
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Popup.Center

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250 }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 200; easing.type: Easing.InBack }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        }
    }

    onClosed: {
        root.oldData = null
    }

    Overlay.modal: Rectangle { color: "#40000000" }

    background: Rectangle {
        color: "#FAFAFA"
        radius: 16
    }

    contentItem: ColumnLayout {
        spacing: 16

        Image {
            source: "../../../../assets/images/warning-mascot.png"
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

            Components.SecondaryButton {
                text: "Cancel"
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                onClicked: root.close()
                enableAnimate: true
            }

            Components.PrimaryButton {
                text: "Delete"
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                enableAnimate: true
                
                buttonColor: "#E53935" 
                textColor: "#FFFFFF"
                
                onClicked: {
                    root.deleteClicked(root.oldData)
                    root.close()
                }
            }
        }
    }
}