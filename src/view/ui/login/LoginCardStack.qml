import QtQuick

Item {
    id: root
    width:  loginScreen.cardWidth  + 64
    height: loginScreen.cardHeight + 32

    signal enterClicked()

    HoverHandler {
        id: stackHover
    }

    // > animation properties
    property real backCardOffset: stackHover.hovered ? -24 : -12
    property real leftCardAngle: stackHover.hovered ? -8 : -5
    property real rightCardAngle: stackHover.hovered ? 8 : 5
    property real frontCardScale: stackHover.hovered ? 1.02 : 1.0

    // >> NOTE: spring controls: 
    //    - spring: speed/acceleration (higher is faster)
    //    - damping: bounciness (closer to 0 is bouncier, 1 is no bounce)
    Behavior on backCardOffset { SpringAnimation { spring: 3.5; damping: 0.25 } }
    Behavior on leftCardAngle  { SpringAnimation { spring: 3.5; damping: 0.25 } }
    Behavior on rightCardAngle { SpringAnimation { spring: 3.5; damping: 0.25 } }
    Behavior on frontCardScale { SpringAnimation { spring: 4.5; damping: 0.3 } }

    // > left tilted card
    Rectangle {
        width:   loginScreen.cardWidth
        height:  loginScreen.cardHeight
        radius:  6
        color:   "#DDDDDD"
        opacity: 0.6
        border { color: appTheme.borderColor; width: 0.5 }
        
        anchors { centerIn: parent; verticalCenterOffset: root.backCardOffset }
        transform: Rotation {
            angle:    root.leftCardAngle
            origin.x: loginScreen.cardWidth / 2
            origin.y: loginScreen.cardHeight
        }
    }

    // > right tilted card
    Rectangle {
        width:   loginScreen.cardWidth
        height:  loginScreen.cardHeight
        radius:  6
        opacity: 0.6
        color:   "#EEEEEE"
        border { color: appTheme.borderColor; width: 0.5 }
        
        anchors { centerIn: parent; verticalCenterOffset: root.backCardOffset }
        transform: Rotation {
            angle:    root.rightCardAngle
            origin.x: loginScreen.cardWidth / 2
            origin.y: loginScreen.cardHeight
        }
    }

    // > front card with content
    LoginCard {
        id: mainCard
        anchors.centerIn: parent
        scale: root.frontCardScale
        
        onEnterClicked: root.enterClicked()
    }
}