import QtQuick
import QtQuick.Controls

Item {
    id: root
    
    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight
    default property alias navigationItems: contentColumn.data

    // NOTE: 
    // - automatically forces all child buttons to act as a single exclusive group.
    // - if you click one, the previously checked one automatically unchecks.
    ButtonGroup {
        id: navGroup
        buttons: contentColumn.children
    }

    Rectangle {
        id: slidingHighlight
        visible: navGroup.checkedButton !== null
        width: navGroup.checkedButton ? navGroup.checkedButton.width : 0
        height: navGroup.checkedButton ? navGroup.checkedButton.height : 0
        y: navGroup.checkedButton ? navGroup.checkedButton.y : 0
        radius: height / 2
        color: "#ECECEC"

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        spacing: 4
    }
}