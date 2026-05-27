import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Popup {
    id: root
    padding: 8
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    default property alias menuItems: contentColumn.data

    background: Item {
        implicitWidth: 100

        Rectangle {
            id: bgShape
            anchors.fill: parent
            radius: 8
            color: "#FFFFFF"
            border.width: 1
            border.color: "#E5E7EB"
            visible: false 
        }

        MultiEffect {
            source: bgShape
            anchors.fill: bgShape
            shadowEnabled: true
            shadowColor: "#25000000" 
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 4
            shadowBlur: 1.0
        }
    }

    contentItem: Column {
        id: contentColumn
        spacing: 0

        function injectMenuReference() {
            for (let i = 0; i < children.length; i++) {
                if (children[i].hostMenu !== undefined) {
                    children[i].hostMenu = root
                }
            }
        }

        Component.onCompleted: injectMenuReference()
        onChildrenChanged: injectMenuReference()
    }
}