import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root

    property string message: ""
    property bool isError: false

    z: 100 
    
    width: Math.min(toastRow.implicitWidth + 40, parent ? parent.width - 40 : 400)
    height: toastRow.implicitHeight + 12
    
    color: isError ? (appTheme.errorColor || "#E53935") : "#333333"
    radius: 8
    opacity: 0.0 
    
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.bottomMargin: 24

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: 0.8
        shadowVerticalOffset: 4
    }

    function showToast(msg, errorFlag = false) {
        hideAnim.stop()
        toastAnim.stop()
        
        root.message = msg
        root.isError = errorFlag
        toastAnim.restart()
    }

    function closeToast() {
        if (toastAnim.running) {
            toastAnim.stop()
        }
        if (!hideAnim.running && root.opacity > 0) {
            hideAnim.restart()
        }
    }

    transform: Translate {
        id: yOffset
        y: 20 
    }

    RowLayout {
        id: toastRow
        anchors.centerIn: parent
        spacing: 10

        Image {
            source: root.isError ? "../../../assets/icons/close.svg" : "../../../assets/icons/check.svg"
            sourceSize: Qt.size(14, 14)
            Layout.alignment: Qt.AlignVCenter
            
            layer.enabled: true
            layer.effect: MultiEffect {
                colorizationColor: "#FFFFFF"
                colorization: 1.0
                brightness: 1.0
            }
        }

        Text {
            id: toastText
            color: "white"
            font.bold: true
            font.pixelSize: 12
            font.family: appTheme.rethinkSansFontName
            text: root.message
            Layout.alignment: Qt.AlignVCenter
        }

        Item { width: 4; height: 1 }

        Rectangle {
            width: 20
            height: 20
            radius: 10
            color: closeMouseArea.containsMouse ? "#33FFFFFF" : "transparent"
            Layout.alignment: Qt.AlignVCenter
            
            Image {
                source: "../../../assets/icons/close.svg"
                sourceSize: Qt.size(12, 12)
                anchors.centerIn: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorizationColor: "#FFFFFF"
                    colorization: 1.0
                    brightness: 1.0
                }
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeToast()
            }
        }
    }

    Rectangle {
        id: toastProgress
        height: 3
        color: "white"
        opacity: 0.4
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.width 
        
        bottomLeftRadius: 8
        bottomRightRadius: 8 
    }

    SequentialAnimation {
        id: toastAnim
        
        PropertyAction { target: yOffset; property: "y"; value: 20 }
        PropertyAction { target: root; property: "opacity"; value: 0.0 }
        PropertyAction { target: toastProgress; property: "width"; value: root.width }

        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 1.0; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { target: yOffset; property: "y"; to: 0; duration: 400; easing.type: Easing.OutCubic }
        }

        NumberAnimation { target: toastProgress; property: "width"; to: 0; duration: 3000 }

        ScriptAction { script: hideAnim.restart() }
    }

    ParallelAnimation {
        id: hideAnim
        NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 300; easing.type: Easing.InCubic }
        NumberAnimation { target: yOffset; property: "y"; to: 20; duration: 300; easing.type: Easing.InCubic }
    }
}