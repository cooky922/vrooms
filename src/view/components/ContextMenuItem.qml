import QtQuick
import QtQuick.Effects

Item {
    id: root
    
    implicitWidth: Math.max(100, leftContent.implicitWidth + rightContent.implicitWidth + 40)
    implicitHeight: 34

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
        anchors.margins: 2
        radius: 6
        
        color: {
            if (mouseArea.pressed) return "#EAEAEA"
            if (mouseArea.containsMouse) return "#EEEEEE"
            return "transparent"
        }
    }

    // > content
    Item {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        
        Row {
            id: leftContent
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Item {
                width: root.iconName !== "" ? 18 : 0
                height: root.iconName !== "" ? 18 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconName !== ""

                Image {
                    id: itemIconImg
                    source: root.iconName !== "" ? root._iconSourceDirectory + root.iconName + ".svg" : ""
                    sourceSize.width: 18
                    sourceSize.height: 18
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: itemIconImg
                    anchors.fill: itemIconImg
                    colorizationColor: "#444746" 
                    colorization: 1.0
                }
            }

            Text {
                text: root.text
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 12
                font.weight: Font.Normal 
                color: "#1F1F1F" 
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
            color: "#5F6368"
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