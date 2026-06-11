import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Popup {
    id: root
    topPadding: 8
    bottomPadding: 8
    leftPadding: 0
    rightPadding: 0
    
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    default property alias menuItems: contentLayout.data

    property real _lastCloseTime: 0
    
    onOpenedChanged: {
        if (!opened) {
            _lastCloseTime = Date.now()
        }
    }

    function toggle() {
        if (Date.now() - _lastCloseTime < 250) {
            return;
        }
        if (opened) {
            close();
        } else {
            open();
        }
    }

    background: Item {        
        Rectangle {
            id: bgShape
            anchors.fill: parent
            radius: 6 
            color: "#FFFFFF"
            visible: false
        }

        MultiEffect {
            source: bgShape
            anchors.fill: bgShape
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