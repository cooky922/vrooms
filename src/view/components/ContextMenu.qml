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
    margins: 0 
    
    // Automatically cap height at 80% of screen to enable scrolling!
    height: Math.min(implicitHeight, Overlay.overlay ? Overlay.overlay.height * 0.8 : 500)
    
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Routes injected children into the Layout inside the ScrollView
    default property alias menuItems: contentLayout.data

    property bool smartPositioning: false 
    property real yOffset: 4
    property bool _isUpward: false

    property real _lastCloseTime: 0
    
    onOpenedChanged: {
        if (!opened) {
            _lastCloseTime = Date.now()
        }
    }

    onAboutToShow: {
        if (smartPositioning && parent) {
            let pos = parent.mapToItem(null, 0, parent.height)
            let winHeight = parent.Window.height
            _isUpward = (pos.y + root.implicitHeight > winHeight - 16)
        }
    }

    Binding {
        target: root
        property: "y"
        value: root._isUpward ? (-root.height - root.yOffset) : (root.parent ? root.parent.height + root.yOffset : 0)
        when: root.smartPositioning
        restoreMode: Binding.RestoreBinding
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

    property real slideOffset: 0

    background: Rectangle {
        color: "#FFFFFF"
        radius: 6 

        transform: Translate { y: root.slideOffset }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#44000000" 
            shadowHorizontalOffset: 2 
            shadowVerticalOffset: 4
            shadowBlur: 1.0
            autoPaddingEnabled: true
        }
    }

    contentItem: ScrollView {
        id: scrollView
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        transform: Translate { y: root.slideOffset }

        ColumnLayout {
            id: contentLayout
            width: scrollView.availableWidth
            spacing: 2
            Layout.fillWidth: true

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

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
            NumberAnimation { property: "slideOffset"; from: root._isUpward ? 10 : -10; to: 0; duration: 150; easing.type: Easing.OutQuad }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InQuad }
            NumberAnimation { property: "slideOffset"; from: 0; to: root._isUpward ? 10 : -10; duration: 100; easing.type: Easing.InQuad }
        }
    }
}