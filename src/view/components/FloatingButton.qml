import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    
    property color buttonColor: "#FFFFFF"
    property int textSize: 12
    property color textColor: "#000000"
    
    property string iconSource: ""
    property string iconPosition: "left"
    property int letterSpacing: 0
    property bool enableAnimate: false

    padding: 10
    leftPadding: 20
    rightPadding: 20

    background: Item {
        Rectangle {
            id: bgShape
            anchors.fill: parent
            
            radius: height / 3
            
            color: {
                if (!root.enabled) return "#D7D7D7"
                if (root.down) return Qt.darker(root.buttonColor, 1.1)
                if (root.hovered) return Qt.darker(root.buttonColor, 1.05)
                return root.buttonColor
            }

            Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.OutQuad } }
            
            visible: false 
        }

        MultiEffect {
            source: bgShape
            anchors.fill: bgShape
            
            shadowEnabled: true
            shadowColor: "#44000000"
            shadowHorizontalOffset: 2
            shadowVerticalOffset: 4
            shadowBlur: 1.0
        }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.iconSource !== "" ? 12 : 0
            layoutDirection: root.iconPosition === "right" ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                width: root.iconSource !== "" ? textSize * 1.2 : 0
                height: root.iconSource !== "" ? textSize * 1.2 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconSource !== ""
                opacity: root.enabled ? 1.0 : 0.5

                Image {
                    id: buttonIcon
                    source: root.iconSource
                    sourceSize.width: textSize * 1.2
                    sourceSize.height: textSize * 1.2
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
                
                font.weight: Font.Medium 
                font.family: appTheme.inclusiveSansFontName
                font.letterSpacing: root.letterSpacing

                anchors.verticalCenter: parent.verticalCenter
                opacity: root.enabled ? 1.0 : 0.5
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
        y: (enableAnimate && root.hovered && !root.down) ? -3 : 0
        Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }
}