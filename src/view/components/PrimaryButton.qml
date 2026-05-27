import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    
    property color buttonColor: appTheme.activeDarkColor
    property int textSize: 12
    property color textColor: "#FFFFFF"
    
    property string iconSource: ""
    property string iconPosition: "left"
    property int letterSpacing: 0
    property bool enableAnimate: false

    padding: 10

    background: Rectangle {
        radius: 6
        border.width: 0
        
        color: {
            if (!root.enabled) return Qt.lighter(root.buttonColor, 1.5)
            if (root.down) return Qt.darker(root.buttonColor, 1.15)
            if (root.hovered) return Qt.darker(root.buttonColor, 1.07)
            return root.buttonColor
        }

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutQuad } }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.iconSource !== "" ? 8 : 0
            layoutDirection: root.iconPosition === "right" ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                width: root.iconSource !== "" ? textSize * 1.1 : 0
                height: root.iconSource !== "" ? textSize * 1.1 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconSource !== ""
                opacity: root.enabled ? 1.0 : 0.6

                Image {
                    id: buttonIcon
                    source: root.iconSource
                    sourceSize.width: textSize * 1.1
                    sourceSize.height: textSize * 1.1
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: buttonIcon
                    anchors.fill: buttonIcon
                    colorizationColor: root.textColor
                    colorization: 1.0
                    brightness: 1.0
                }
            }

            Text {
                text: root.text
                color: root.textColor
                font.pixelSize: textSize
                font.bold: true
                font.family: appTheme.rethinkSansFontName
                font.letterSpacing: root.letterSpacing

                anchors.verticalCenter: parent.verticalCenter
                opacity: root.enabled ? 1.0 : 0.6
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    scale: (enableAnimate && root.down) ? 0.97 : 1.0
    Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }

    transform: Translate {
        y: (enableAnimate && root.hovered && !root.down) ? -2 : 0
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }
}