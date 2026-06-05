import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Popup {
    id: root
    padding: 20 
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    default property alias menuItems: contentLayout.data

    background: Item {        
        Rectangle {
            id: bgShape
            anchors.fill: parent
            anchors.margins: 16
            radius: 6 
            color: "#FFFFFF"
            visible: false
        }

        MultiEffect {
            source: bgShape
            
            x: bgShape.x
            y: bgShape.y
            width: bgShape.width
            height: bgShape.height
            
            autoPaddingEnabled: true 
            shadowEnabled: true
            shadowColor: "#44000000"
            shadowHorizontalOffset: 2
            shadowVerticalOffset: 4
            shadowBlur: 1.0
        }
    }

    contentItem: ColumnLayout {
        id: contentLayout
        spacing: 2 

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