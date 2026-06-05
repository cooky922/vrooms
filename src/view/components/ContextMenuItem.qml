import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root
    
    implicitWidth: Math.max(100, leftContent.implicitWidth + rightContent.implicitWidth + 32)
    implicitHeight: 26

    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    property string text: ""
    property string iconName: ""
    property string shortcutText: ""

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
        color: mouseArea.pressed ? "#E5E7EB" : (mouseArea.containsMouse ? "#F3F4F6" : "transparent")
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
                width: root.iconName !== "" ? 16 : 0
                height: root.iconName !== "" ? 16 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconName !== ""

                Image {
                    id: itemIconImg
                    source: root.iconName !== "" ? root._iconSourceDirectory + root.iconName + ".svg" : ""
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: itemIconImg
                    anchors.fill: itemIconImg
                    colorizationColor: "#4B5563"
                    colorization: 1.0
                }
            }

            Text {
                text: root.text
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#333333" 
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
            if (root.hostMenu) {
                root.hostMenu.visible = false
                root.hostMenu.close()
            }
            executeTimer.start()
        }
    }
}