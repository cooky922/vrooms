import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: control
    width: parent ? parent.width : 200
    implicitHeight: 30
    checkable: true 

    property string iconName: ""
    readonly property string _iconSourceDirectory: "../../../assets/icons/"

    contentItem: Item {
        anchors.fill: parent

        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            
            x: 16 + ((control.hovered && !control.checked) ? 6 : 0)

            Behavior on x { 
                NumberAnimation { 
                    duration: 200 
                    easing.type: Easing.OutCirc 
                } 
            }

            // > icon
            Item {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                opacity: control.checked ? 1.0 : 0.5
                visible: control.iconName !== ""

                Image {
                    id: iconImg
                    source: control.iconName !== "" ? control._iconSourceDirectory + control.iconName + ".svg" : ""
                    sourceSize.width: 20
                    sourceSize.height: 20
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: iconImg
                    anchors.fill: iconImg
                    colorizationColor: control.checked ? "black" : "#888888"
                    colorization: 1.0
                }
            }

            // > text
            Text {
                text: control.text
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 12
                font.bold: true
                color: control.checked ? "black" : "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    background: Rectangle {
        anchors.fill: parent
        radius: height / 2 
        
        color: {
            if (control.hovered && !control.checked) return "#EFEFEF"
            return "transparent"
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: control.checked ? Qt.ArrowCursor : Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}