import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Components

Popup {
    id: popup
    
    width: 300
    height: 420
    padding: 0
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    property int selYear: new Date().getFullYear()
    property int selMonth: new Date().getMonth()
    property int selDay: new Date().getDate()

    property int tempYear: new Date().getFullYear()
    property int tempMonth: new Date().getMonth()
    property int tempDay: new Date().getDate()

    property int viewMode: 3

    property var monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property var yearArray: {
        let arr = []
        let current = new Date().getFullYear()
        for (let i = current - 30; i <= current + 20; i++) {
            arr.push(i.toString())
        }
        return arr
    }

    signal dateSelected(int year, int month, int day)

    function daysInMonth(y, m) { 
        return new Date(y, m + 1, 0).getDate()
    }
    
    function firstDayOfMonth(y, m) { 
        return new Date(y, m, 1).getDay()
    }

    onTempMonthChanged: clampDay()
    onTempYearChanged: clampDay()
    
    function clampDay() {
        var maxD = daysInMonth(tempYear, tempMonth)
        if (tempDay > maxD) {
            tempDay = maxD
        }
    }

    onOpened: {
        tempYear = selYear === 0 ? new Date().getFullYear() : selYear
        tempMonth = selMonth
        tempDay = selDay === 0 ? new Date().getDate() : selDay
        viewMode = 3
    }

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
        
        property int activeSize: 16
        property int inactiveSize: 13
        property bool isNumericMode: false
        property int numericStart: 0
        
        wheelEnabled: false
        visibleItemCount: 5
        wrap: true

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

        // ==========================================
        // MAIN HEADER & TOGGLE
        // ==========================================
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            
            Text { 
                anchors.centerIn: parent
                text: "Select Date"
                font.pixelSize: 14
                font.bold: true
                font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                color: "black" 
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 14
                color: modeHov.containsMouse ? "#E5E7EB" : "transparent"
                
                Image { 
                    anchors.centerIn: parent
                    source: viewMode === 3 ? "../../../../../assets/icons/calendar.svg" : "../../../../../assets/icons/sort.svg" 
                    sourceSize: Qt.size(14, 14)
                    opacity: 0.8 
                }
                
                MouseArea {
                    id: modeHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: viewMode = viewMode === 3 ? 0 : 3 
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
        // SUB-HEADER (Used in modes 0, 1, 2)
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            visible: viewMode !== 3

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: prevArea.containsMouse ? "#E5E7EB" : "transparent"
                
                Text { 
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "‹"
                    font.pixelSize: 18
                    color: "black" 
                }
                
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (tempMonth === 0) { tempMonth = 11; tempYear-- }
                        else tempMonth--
                    }
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                Rectangle {
                    Layout.preferredWidth: monthHeaderTxt.implicitWidth + 12
                    Layout.preferredHeight: 26
                    radius: 6
                    color: viewMode === 1 ? "black" : (mHov.containsMouse ? "#E5E7EB" : "transparent")
                    
                    Text {
                        id: monthHeaderTxt
                        anchors.centerIn: parent
                        text: monthNames[tempMonth]
                        font.pixelSize: 13
                        font.bold: true
                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                        color: viewMode === 1 ? "white" : "black"
                    }
                    MouseArea {
                        id: mHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: viewMode = (viewMode === 1 ? 0 : 1) 
                    }
                }

                Rectangle {
                    Layout.preferredWidth: yearHeaderTxt.implicitWidth + 12
                    Layout.preferredHeight: 26
                    radius: 6
                    color: viewMode === 2 ? "black" : (yHov.containsMouse ? "#E5E7EB" : "transparent")
                    
                    Text {
                        id: yearHeaderTxt
                        anchors.centerIn: parent
                        text: tempYear.toString()
                        font.pixelSize: 13
                        font.bold: true
                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                        color: viewMode === 2 ? "white" : "black"
                    }
                    MouseArea {
                        id: yHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: viewMode = (viewMode === 2 ? 0 : 2) 
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: nextArea.containsMouse ? "#E5E7EB" : "transparent"
                
                Text { 
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "›"
                    font.pixelSize: 18
                    color: "black" 
                }
                
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (tempMonth === 11) { tempMonth = 0; tempYear++ }
                        else tempMonth++
                    }
                }
            }
        }

        // ==========================================
        // BODY VIEWS
        // ==========================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- View 0: Standard Calendar ---
            ColumnLayout {
                anchors.fill: parent
                visible: viewMode === 0
                spacing: 6

                Grid {
                    columns: 7; Layout.fillWidth: true; Layout.alignment: Qt.AlignHCenter; spacing: 4
                    Repeater {
                        model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                        Text { width: 32; height: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: modelData; font.pixelSize: 10; font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"; color: "#9CA3AF" }
                    }
                    Repeater { model: popup.firstDayOfMonth(tempYear, tempMonth); Item { width: 32; height: 32 } }
                    Repeater {
                        model: popup.daysInMonth(tempYear, tempMonth)
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            property int dayNum: index + 1
                            property bool isSelected: tempDay === dayNum
                            property bool isToday: {
                                let today = new Date()
                                return today.getDate() === dayNum && today.getMonth() === tempMonth && today.getFullYear() === tempYear
                            }
                            color: isSelected ? "black" : (dayHover.containsMouse ? "#E5E7EB" : "transparent")
                            border.color: isToday && !isSelected ? "black" : "transparent"
                            border.width: isToday && !isSelected ? 1.5 : 0
                            Text { anchors.centerIn: parent; text: parent.dayNum; font.pixelSize: 12; font.bold: parent.isSelected || parent.isToday; font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"; color: parent.isSelected ? "white" : "black" }
                            MouseArea { id: dayHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: tempDay = parent.dayNum }
                        }
                    }
                }
            }

            // --- View 1: Month Grid ---
            Grid {
                anchors.centerIn: parent
                visible: viewMode === 1
                columns: 3; spacing: 12
                Repeater {
                    model: monthNames
                    Rectangle {
                        width: 70; height: 40; radius: 8
                        color: index === tempMonth ? "black" : (mgHover.containsMouse ? "#E5E7EB" : "#F3F4F6")
                        Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 12; font.bold: index === tempMonth; font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"; color: index === tempMonth ? "white" : "black" }
                        MouseArea { id: mgHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { tempMonth = index; viewMode = 0 } }
                    }
                }
            }

            // --- View 2: Single Year Wheel ---
            Item {
                anchors.fill: parent
                visible: viewMode === 2
                Rectangle { anchors.centerIn: parent; width: 100; height: 32; color: "#F3F4F6"; radius: 8 }
                
                FastTumbler {
                    id: yearSingleWheel
                    anchors.centerIn: parent
                    height: parent.height; width: 100
                    model: yearArray
                    
                    property bool ignoreIndex: false
                    
                    Connections {
                        target: popup
                        function onTempYearChanged() {
                            if (!yearSingleWheel.ignoreIndex && yearSingleWheel.currentIndex !== popup.tempYear - parseInt(popup.yearArray[0])) {
                                yearSingleWheel.ignoreIndex = true
                                yearSingleWheel.currentIndex = popup.tempYear - parseInt(popup.yearArray[0])
                                yearSingleWheel.ignoreIndex = false
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                            popup.tempYear = parseInt(yearArray[currentIndex])
                        }
                    }
                    Component.onCompleted: currentIndex = popup.tempYear - parseInt(popup.yearArray[0])
                }
            }

            // --- View 3: Full Slider (Y/M/D) ---
            Item {
                anchors.fill: parent
                visible: viewMode === 3

                Rectangle { anchors.centerIn: parent; width: parent.width; height: 32; color: "#F3F4F6"; radius: 8 }
                
                RowLayout {
                    anchors.fill: parent
                    
                    // YEAR TUMBLER
                    FastTumbler {
                        id: yT
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: yearArray
                        property bool ignoreIndex: false
                        
                        Connections {
                            target: popup
                            function onTempYearChanged() {
                                if (!yT.ignoreIndex && yT.currentIndex !== popup.tempYear - parseInt(popup.yearArray[0])) {
                                    yT.ignoreIndex = true
                                    yT.currentIndex = popup.tempYear - parseInt(popup.yearArray[0])
                                    yT.ignoreIndex = false
                                }
                            }
                        }
                        onCurrentIndexChanged: {
                            if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                                popup.tempYear = parseInt(yearArray[currentIndex])
                            }
                        }
                        Component.onCompleted: currentIndex = popup.tempYear - parseInt(popup.yearArray[0])
                    }
                    
                    // MONTH TUMBLER
                    FastTumbler {
                        id: mT
                        Layout.fillWidth: true; Layout.fillHeight: true
                        model: monthNames
                        property bool ignoreIndex: false
                        
                        Connections {
                            target: popup
                            function onTempMonthChanged() {
                                if (!mT.ignoreIndex && mT.currentIndex !== popup.tempMonth) {
                                    mT.ignoreIndex = true
                                    mT.currentIndex = popup.tempMonth
                                    mT.ignoreIndex = false
                                }
                            }
                        }
                        onCurrentIndexChanged: {
                            if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                                popup.tempMonth = currentIndex
                            }
                        }
                        Component.onCompleted: currentIndex = popup.tempMonth
                    }
                    
                    // DAY TUMBLER
                    FastTumbler {
                        id: dT
                        Layout.fillWidth: true; Layout.fillHeight: true
                        isNumericMode: true; numericStart: 1
                        property bool ignoreIndex: false

                        function syncModel() {
                            ignoreIndex = true
                            var maxD = popup.daysInMonth(popup.tempYear, popup.tempMonth)
                            if (model !== maxD) model = maxD
                            currentIndex = popup.tempDay - 1
                            ignoreIndex = false
                        }

                        Component.onCompleted: syncModel()

                        Connections {
                            target: popup
                            function onTempMonthChanged() { dT.syncModel() }
                            function onTempYearChanged() { dT.syncModel() }
                            function onTempDayChanged() {
                                if (!dT.ignoreIndex && dT.currentIndex !== popup.tempDay - 1) {
                                    dT.ignoreIndex = true
                                    dT.currentIndex = popup.tempDay - 1
                                    dT.ignoreIndex = false
                                }
                            }
                        }

                        onCurrentIndexChanged: {
                            if (!ignoreIndex && currentIndex >= 0 && currentIndex < count) {
                                popup.tempDay = currentIndex + 1
                            }
                        }
                    }
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
                text: "Today"
                Layout.preferredHeight: 32
                enableAnimate: true
                buttonColor: "#F3F4F6"
                textColor: "#111827"
                onClicked: {
                    var d = new Date()
                    // Bindings perfectly cascade safely to all tumblers now
                    popup.tempYear = d.getFullYear()
                    popup.tempMonth = d.getMonth()
                    popup.tempDay = d.getDate()
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
                    selYear = tempYear
                    selMonth = tempMonth
                    selDay = tempDay
                    popup.dateSelected(selYear, selMonth, selDay)
                    popup.close()
                }
            }
        }
    }
}