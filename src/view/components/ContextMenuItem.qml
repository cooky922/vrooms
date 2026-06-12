import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root
    property string text: ""
    property string iconName: ""
    property string shortcutText: ""
    property color itemColor: "transparent"
    
    property bool checkable: false
    property bool checked: false
    property bool autoClose: true 
    
    implicitWidth: Math.max(100, leftContent.implicitWidth + rightContent.implicitWidth + 32)
    implicitHeight: 26

    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    property var hostMenu: null
    
    signal triggered()

    Timer {
        id: executeTimer
        interval: 10 
        repeat: false
        onTriggered: root.triggered()
    }

    readonly property string _iconSourceDirectory: "../../../assets/icons/"

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: 4 
        
        color: {
            if (root.checked) {
                if (mouseArea.pressed) return "#C2D7FA"
                if (mouseArea.containsMouse) return "#D2E3FC"
                return "#E8F0FE"
            }
            
            if (root.itemColor.a === 0) {
                if (mouseArea.pressed) return "#E5E7EB"
                if (mouseArea.containsMouse) return "#F3F4F6"
                return "transparent"
            } else {
                if (mouseArea.pressed) return Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.15)
                if (mouseArea.containsMouse) return Qt.rgba(root.itemColor.r, root.itemColor.g, root.itemColor.b, 0.1)
                return "transparent"
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        
        Row {
            id: leftContent
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Item {
                property bool hasIcon: root.checkable || root.iconName !== ""
                width: hasIcon ? 16 : 0
                height: hasIcon ? 16 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: hasIcon

                Image {
                    id: checkIconImage
                    source: root._iconSourceDirectory + "check.svg"
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.fill: parent
                    visible: false
                }

                Image {
                    id: itemIconImg
                    source: root.iconName !== "" ? root._iconSourceDirectory + root.iconName + ".svg" : ""
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    id: iconEffect
                    anchors.fill: parent
                    source: (root.checkable && root.checked) ? checkIconImage : itemIconImg
                    colorizationColor: root.checked ? "#1A73E8" : (root.itemColor.a === 0 ? "#333333" : root.itemColor)
                    colorization: 1.0
                    brightness: 1.0
                }
            }

            Text {
                text: root.text
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 12
                font.weight: Font.Medium
                color: root.isHighlighted ? "#1A73E8" : (root.itemColor.a === 0 ? "#333333" : root.itemColor)
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            id: rightContent
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.shortcutText
            font.family: appTheme.inclusiveSansFontName
            font.pixelSize: 10
            color: "#9CA3AF" 
            visible: root.shortcutText !== ""
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (root.autoClose && root.hostMenu) {
                root.hostMenu.visible = false
                root.hostMenu.close()
            }
            executeTimer.start()
        }
    }
}