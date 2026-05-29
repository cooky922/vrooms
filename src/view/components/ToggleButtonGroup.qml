import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property alias checkedButton: btnGroup.checkedButton

    implicitWidth: contentRow.implicitWidth + (Math.ceil(border.width) * 2)
    implicitHeight: 26

    radius: height / 2
    color: "transparent"
    border.color: "#888888" 
    border.width: 0.75

    default property alias buttons: contentRow.data

    ButtonGroup {
        id: btnGroup
        buttons: contentRow.children
    }

    // > sliding highlight background (only visible when a button is checked)
    Item {
        anchors.fill: parent
        anchors.margins: Math.ceil(root.border.width) 
        visible: btnGroup.checkedButton !== null

        Rectangle {
            id: slidingHighlight
            
            x: btnGroup.checkedButton ? btnGroup.checkedButton.x : 0
            y: 0
            width: btnGroup.checkedButton ? btnGroup.checkedButton.width : 0
            height: parent.height 
            
            color: "#C2E7FF" 
            radius: height / 2

            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            // Square off LEFT edge if NOT the first button
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.radius
                color: parent.color
                visible: {
                    if (!btnGroup.checkedButton) return false;
                    return btnGroup.checkedButton !== contentRow.children[0]
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.radius
                color: parent.color
                visible: {
                    if (!btnGroup.checkedButton) return false;
                    return btnGroup.checkedButton !== contentRow.children[contentRow.children.length - 1]
                }
            }
        }
    }

    // > content row
    Row {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Math.ceil(root.border.width)
        spacing: 0
    }
}