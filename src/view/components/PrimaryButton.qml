import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    
    property color buttonColor: "#ECECEC"
    property int textSize: 12
    property color textColor: "black"
    
    property string iconName: ""
    property string iconPosition: "left"
    property int letterSpacing: 0
    property bool enableAnimate: false

    readonly property string _iconSourceDirectory: "../../../assets/icons/"
    leftPadding: 10
    rightPadding: 10
    topPadding: 5
    bottomPadding: 5

    background: Rectangle {
        radius: root.height / 2
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
            spacing: root.iconName !== "" ? 8 : 0
            layoutDirection: root.iconPosition === "right" ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                width: root.iconName !== "" ? textSize * 1.5 : 0
                height: root.iconName !== "" ? textSize * 1.5 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconName !== ""
                opacity: root.enabled ? 1.0 : 0.6

                Image {
                    id: buttonIcon
                    source: root.iconName === "" ? "" : root._iconSourceDirectory + root.iconName + ".svg"
                    sourceSize.width: textSize * 1.5
                    sourceSize.height: textSize * 1.5
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
                font.family: appTheme.inclusiveSansFontName
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