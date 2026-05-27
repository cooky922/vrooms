import QtQuick
import QtQuick.Layouts
import "../../components" as Components

Rectangle {
    id: root
    width:   loginScreen.cardWidth
    height:  loginScreen.cardHeight
    radius:  6
    color:   "white"
    border { color: appTheme.borderColor; width: 0.75 }

    signal enterClicked()

    // > shadow
    Rectangle {
        z: -1
        width: parent.width  + 10
        height: parent.height + 10
        radius: parent.radius + 5
        color: "transparent"
        border { color: "#0000001A"; width: 5 }
        anchors { centerIn: parent; verticalCenterOffset: 5 }
    }

    // > card content layout
    ColumnLayout {
        anchors { fill: parent; margins: 20 }
        spacing: 0

        // >> heading
        Components.TitleText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            text:  "Hello User!"
        }

        Item { Layout.fillHeight: true }

        // >> mascot
        Image {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            id: mascot
            source: "../../../../assets/images/vrooms-mascot.png"
            
            width: 120
            height: 120
            sourceSize.width: 120
            sourceSize.height: 120

            fillMode: Image.PreserveAspectFit
        }

        Item { Layout.fillHeight: true }

        // >> instruction
        Components.InfoText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10

            text:  "Press Enter to Open the System"
            font.letterSpacing: 1
            font.bold: true
        }

        Item { Layout.preferredHeight: 5 }

        // >> enter button
        Components.ActionButton {
            Layout.fillWidth: true

            text: "ENTER"
            letterSpacing: 3
            enableAnimate: true
            buttonColor: appTheme.activeDarkColor
            padding: 4

            onClicked: root.enterClicked()
        }
    }
}
