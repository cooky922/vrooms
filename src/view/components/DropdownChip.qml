import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "." as Components

Item {
    id: root

    property string label: "Placeholder"
    property string selectedValue: ""
    property var model: [] 
    
    property bool isSmall: false
    property color parentBgColor: "#FFFFFF"

    readonly property bool hasSelection: selectedValue !== ""

    property string clearIconName: "close"        
    property string arrowIconName: "down"         
    readonly property string _iconSourceDirectory: "../../../assets/icons/"

    default property alias menuItems: chipMenu.contentData

    // NOTE: keeps track of items we've already bound so we don't double-trigger
    property var _boundItems: []

    function autoBindItems() {
        for (let i = 0; i < chipMenu.contentData.length; i++) {
            let child = chipMenu.contentData[i]
            
            if (child.text !== undefined && child.triggered !== undefined) {
                if (root._boundItems.indexOf(child) === -1) {
                    root._boundItems.push(child)
                    child.triggered.connect(function() {
                        root.selectedValue = child.text
                    })
                }
            }
        }
    }

    Component.onCompleted: autoBindItems()
    onMenuItemsChanged: autoBindItems()

    property real chipLeftPadding: root.isSmall ? 12 : 16
    property real chipRightPadding: root.hasSelection ? (root.isSmall ? 4 : 6) : (root.isSmall ? 8 : 12)
    implicitWidth: contentRow.implicitWidth + chipLeftPadding + chipRightPadding
    implicitHeight: root.isSmall ? 26 : 30

    property real rightSplitWidth: root.hasSelection ? (closeRow.implicitWidth + root.chipRightPadding) : 0
    Behavior on rightSplitWidth { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    property bool isHovered: chipMouseArea.containsMouse || (root.hasSelection && clearArea.containsMouse)
    property bool isPressed: chipMouseArea.pressed || (root.hasSelection && clearArea.pressed)

    Item {
        id: container
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        
        anchors.verticalCenterOffset: (root.isHovered && !root.isPressed) ? -2 : 0
        scale: root.isPressed ? 0.97 : 1.0

        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

        // > chip background
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            
            color: root.hasSelection ? "#C2E7FF" : "transparent"
            border.color: root.hasSelection ? "transparent" : "#888888"
            border.width: root.hasSelection ? 0 : 0.75

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }

        // > chip content
        Row {
            id: contentRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.chipLeftPadding
            spacing: root.isSmall ? 2 : 4

            // > text label
            Text {
                text: root.hasSelection ? root.selectedValue : root.label
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: root.isSmall ? 12 : 13
                font.weight: Font.Medium
                color: root.hasSelection ? "#001D35" : "#444746"
                anchors.verticalCenter: parent.verticalCenter
            }

            // > dropdown arrow
            Item {
                width: root.isSmall ? 20 : 22
                height: root.isSmall ? 20 : 22
                anchors.verticalCenter: parent.verticalCenter
                
                rotation: chipMenu.visible ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: chipMouseArea.pressed ? "#26001D35" : (chipMouseArea.containsMouse ? "#1A001D35" : "transparent")
                    scale: chipMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Image {
                    id: arrowIcon
                    source: root._iconSourceDirectory + root.arrowIconName + ".svg"
                    sourceSize.width: root.isSmall ? 12 : 14
                    sourceSize.height: root.isSmall ? 12 : 14
                    anchors.centerIn: parent
                    visible: false
                }

                MultiEffect {
                    source: arrowIcon
                    anchors.fill: arrowIcon
                    colorizationColor: root.hasSelection ? "#001D35" : "#444746"
                    colorization: 1.0
                }
            }

            // > separator and close icon (only visible when there's a selection)
            Item {
                id: closeSection
                width: root.hasSelection ? closeRow.implicitWidth : 0
                height: container.height 
                anchors.verticalCenter: parent.verticalCenter
                clip: true 

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                Row {
                    id: closeRow
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.isSmall ? 2 : 4

                    // >> separator
                    Rectangle {
                        width: 2
                        height: container.height 
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.parentBgColor 
                    }

                    // >> close icon
                    Item {
                        width: root.isSmall ? 20 : 22
                        height: root.isSmall ? 20 : 22
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: clearArea.pressed ? "#26001D35" : (clearArea.containsMouse ? "#1A001D35" : "transparent")
                            scale: clearArea.pressed ? 0.9 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                        }

                        Image {
                            id: closeIcon
                            source: root._iconSourceDirectory + root.clearIconName + ".svg"
                            sourceSize.width: root.isSmall ? 12 : 14
                            sourceSize.height: root.isSmall ? 12 : 14
                            anchors.centerIn: parent
                            visible: false
                        }

                        MultiEffect {
                            source: closeIcon
                            anchors.fill: closeIcon
                            colorizationColor: "#001D35"
                            colorization: 1.0
                        }
                    }
                }
            }
        }
        
        MouseArea {
            id: chipMouseArea
            anchors.left: parent.left
            anchors.right: root.hasSelection ? clearArea.left : parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (chipMenu.opened) chipMenu.close()
                else chipMenu.open()
            }
        }

        MouseArea {
            id: clearArea
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.rightSplitWidth
            visible: root.hasSelection
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                root.selectedValue = ""
            }
        }
    }

    // > dropdown menu
    Components.ContextMenu {
        id: chipMenu
        y: root.height - 12 + (chipMenu.slideOffset !== undefined ? chipMenu.slideOffset : 0)
        x: -16

        // NOTE: automatically generates options if the `model` array is used
        Repeater {
            model: root.model
            Components.ContextMenuItem {
                text: modelData
                onTriggered: root.selectedValue = modelData
            }
        }
    }
}