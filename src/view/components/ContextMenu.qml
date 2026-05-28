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

    property real slideOffset: 0

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "slideOffset"; from: -10; to: 0; duration: 150; easing.type: Easing.OutQuad }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InQuad }
            NumberAnimation { property: "slideOffset"; from: 0; to: -10; duration: 100; easing.type: Easing.InQuad }
        }
    }
}