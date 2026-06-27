import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Components

Popup {
    id: popup
    
    width: 320
    height: 320
    padding: 0
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    property int selHour: 12
    property int selMinute: 0
    property int selSecond: 0
    property string timeAmPm: "AM"

    signal timeSelected(int h24, int min, int sec)

    property var ampmModel: ["AM", "PM"]

    Overlay.modal: Rectangle { color: "#66000000" }

    background: Rectangle {
        color: "#FFFFFF"
        radius: 12
        border.color: "#E5E7EB"
        border.width: 1
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
        NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
    }
    
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
    }

    component FastTumbler: Tumbler {
        id: ft
        
        property int activeSize: 18
        property int inactiveSize: 13
        property bool isNumericMode: false
        property int numericStart: 0
        
        wheelEnabled: false
        visibleItemCount: 5
        wrap: true // Infinite wrapping for all

        function increment() {
            if (ft.wrap) ft.currentIndex = (ft.currentIndex + 1) % ft.count
            else ft.currentIndex = Math.min(ft.count - 1, ft.currentIndex + 1)
        }

        function decrement() {
            if (ft.wrap) ft.currentIndex = (ft.currentIndex - 1 + ft.count) % ft.count
            else ft.currentIndex = Math.max(0, ft.currentIndex - 1)
        }

        contentItem: ListView {
            anchors.fill: parent
            model: ft.model
            delegate: ft.delegate
            currentIndex: ft.currentIndex
            clip: true

            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange

            highlightMoveDuration: 50  
            highlightMoveVelocity: -1 

            property real itemH: height / ft.visibleItemCount
            preferredHighlightBegin: (height / 2) - (itemH / 2)
            preferredHighlightEnd: (height / 2) + (itemH / 2)

            onCurrentIndexChanged: {
                if (ft.currentIndex !== currentIndex) {
                    ft.currentIndex = currentIndex
                }
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            property bool processing: false
            property int scrollAccumulator: 0
            
            onWheel: (event) => {
                if (processing) return
                processing = true
                
                scrollAccumulator += event.angleDelta.y
                while (scrollAccumulator >= 120) {
                    ft.decrement()
                    scrollAccumulator -= 120
                }
                while (scrollAccumulator <= -120) {
                    ft.increment()
                    scrollAccumulator += 120
                }
                processing = false
            }
        }

        delegate: Text {
            text: ft.isNumericMode ? String(index + ft.numericStart).padStart(2, '0') : (typeof modelData !== "undefined" ? modelData : "")
            font.pixelSize: Math.abs(Tumbler.displacement) < 0.5 ? ft.activeSize : ft.inactiveSize
            font.bold: Math.abs(Tumbler.displacement) < 0.5
            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
            color: Math.abs(Tumbler.displacement) < 0.5 ? "black" : "#9CA3AF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: 1.0 - (Math.abs(Tumbler.displacement) * 0.25)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Title
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Text {
                anchors.centerIn: parent
                text: "Select Time"
                font.pixelSize: 14
                font.bold: true
                font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                color: "black"
            }
        }

        // Edge-to-Edge Separator
        Rectangle { 
            Layout.fillWidth: true
            Layout.leftMargin: -16
            Layout.rightMargin: -16
            Layout.preferredHeight: 1.5
            color: "#D1D5DB" 
        }

        // ==========================================
        // TUMBLER SCROLL WHEELS
        // ==========================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 32
                color: "#F3F4F6"
                radius: 8
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Hours
                FastTumbler {
                    id: hourT
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: 12
                    isNumericMode: true; numericStart: 1
                    property bool ignoreIndex: false
                    
                    Connections {
                        target: popup
                        function onSelHourChanged() {
                            if (!hourT.ignoreIndex && hourT.currentIndex !== popup.selHour - 1) {
                                hourT.ignoreIndex = true
                                hourT.currentIndex = popup.selHour - 1
                                hourT.ignoreIndex = false
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                            popup.selHour = currentIndex + 1
                        }
                    }
                    Component.onCompleted: currentIndex = popup.selHour - 1
                }
                
                Text { text: ":"; font.pixelSize: 18; font.bold: true; color: "black"; Layout.alignment: Qt.AlignVCenter }

                // Minutes
                FastTumbler {
                    id: minT
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: 60
                    isNumericMode: true; numericStart: 0
                    property bool ignoreIndex: false
                    
                    Connections {
                        target: popup
                        function onSelMinuteChanged() {
                            if (!minT.ignoreIndex && minT.currentIndex !== popup.selMinute) {
                                minT.ignoreIndex = true
                                minT.currentIndex = popup.selMinute
                                minT.ignoreIndex = false
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                            popup.selMinute = currentIndex
                        }
                    }
                    Component.onCompleted: currentIndex = popup.selMinute
                }

                Text { text: ":"; font.pixelSize: 18; font.bold: true; color: "black"; Layout.alignment: Qt.AlignVCenter }

                // Seconds
                FastTumbler {
                    id: secT
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: 60
                    isNumericMode: true; numericStart: 0
                    property bool ignoreIndex: false
                    
                    Connections {
                        target: popup
                        function onSelSecondChanged() {
                            if (!secT.ignoreIndex && secT.currentIndex !== popup.selSecond) {
                                secT.ignoreIndex = true
                                secT.currentIndex = popup.selSecond
                                secT.ignoreIndex = false
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                            popup.selSecond = currentIndex
                        }
                    }
                    Component.onCompleted: currentIndex = popup.selSecond
                }

                Item { Layout.preferredWidth: 8 }

                // AM / PM
                FastTumbler {
                    id: ampmT
                    Layout.fillWidth: true; Layout.fillHeight: true
                    model: ampmModel
                    property bool ignoreIndex: false
                    
                    Connections {
                        target: popup
                        function onTimeAmPmChanged() {
                            let targetIdx = popup.timeAmPm === "AM" ? 0 : 1
                            if (!ampmT.ignoreIndex && ampmT.currentIndex !== targetIdx) {
                                ampmT.ignoreIndex = true
                                ampmT.currentIndex = targetIdx
                                ampmT.ignoreIndex = false
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                            popup.timeAmPm = currentIndex === 0 ? "AM" : "PM"
                        }
                    }
                    Component.onCompleted: currentIndex = popup.timeAmPm === "AM" ? 0 : 1
                }
            }
        }

        // Edge-to-Edge Separator
        Rectangle { 
            Layout.fillWidth: true
            Layout.leftMargin: -16
            Layout.rightMargin: -16
            Layout.preferredHeight: 1.5
            color: "#D1D5DB" 
        }

        // ==========================================
        // BOTTOM BUTTONS
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Components.PrimaryButton {
                text: "Now"
                Layout.preferredHeight: 32
                enableAnimate: true
                buttonColor: "#F3F4F6"
                textColor: "#111827"
                onClicked: {
                    var c = new Date()
                    var h = c.getHours()
                    popup.timeAmPm = h >= 12 ? "PM" : "AM"
                    popup.selHour = (h % 12 === 0 ? 12 : h % 12)
                    popup.selMinute = c.getMinutes()
                    popup.selSecond = c.getSeconds()
                }
            }

            Item { Layout.fillWidth: true } 

            Components.SecondaryButton {
                text: "Cancel"
                Layout.preferredHeight: 32
                enableAnimate: true
                onClicked: popup.close()
            }

            Components.PrimaryButton {
                text: "OK"
                Layout.preferredHeight: 32
                enableAnimate: true
                buttonColor: "black"
                textColor: "#FFFFFF"
                onClicked: {
                    var h24 = selHour
                    if (timeAmPm === "AM") { 
                        if (h24 === 12) h24 = 0 
                    } else { 
                        if (h24 !== 12) h24 += 12 
                    }
                    
                    popup.timeSelected(h24, selMinute, selSecond)
                    popup.close()
                }
            }
        }
    }
}