import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    property string placeholderText: "YYYY-MM-DD HH:MM:SS"
    property bool isViewOnly: false
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6

    //Calendar + time picker state
    property int _selYear:   new Date().getFullYear()
    property int _selMonth:  new Date().getMonth()
    property int _selDay:    0
    property int _selHour:   new Date().getHours()
    property int _selMinute: new Date().getMinutes()
    property int _selSecond: new Date().getSeconds()
    property string _timeAmPm: "AM"

    function _applyDateTime() {
        if (root._selDay === 0) return
        var mm  = String(root._selMonth + 1).padStart(2, '0')
        var dd  = String(root._selDay).padStart(2, '0')
        var hh  = String(root._selHour).padStart(2, '0')
        var min = String(root._selMinute).padStart(2, '0')
        var ss  = String(root._selSecond).padStart(2, '0')
        var str = root._selYear + "-" + mm + "-" + dd + " " + hh + ":" + min + ":" + ss
        field.text = str
        root.inputValueChanged(root.fieldKey, str)
    }

    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function _firstDayOfMonth(y, m) { return new Date(y, m, 1).getDay() }
    //End calendar + time picker state

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
        color: "#333"
    }

    TextField {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        placeholderText: root.isViewOnly ? "-" : root.placeholderText
        leftPadding: 12
        rightPadding: (!root.isViewOnly && field.text === "") ? nowBtn.width + 12 : 56
        font { pixelSize: 12; family: appTheme.rethinkSansFontName }
        
        readOnly: root.isViewOnly
        color: root.isViewOnly ? "#666666" : "#333"
        placeholderTextColor: "#AAAAAA"
        
        text: root.value !== undefined ? root.value : ""
        onTextEdited: root.inputValueChanged(root.fieldKey, text)

        background: Rectangle {
            radius: 15
            color: root.isViewOnly ? "#EEEEEE" : "transparent"
            border.color: root.isViewOnly ? "transparent" : (field.activeFocus ? appTheme.activeColor : "#888888")
            border.width: field.activeFocus && !root.isViewOnly ? 2 : (root.isViewOnly ? 0 : 0.75)
        }

        HoverHandler { 
            id: hover 
        }
        
        transform: Translate { 
            y: (hover.hovered && !root.isViewOnly) ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } } 
        }

        Rectangle {
            id: nowBtn
            visible: !root.isViewOnly && field.text === ""
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            height: 24
            width: nowRow.implicitWidth + 16
            radius: 12
            color: nowMouseArea.containsMouse ? "#E5E7EB" : "transparent"
            
            Row {
                id: nowRow
                anchors.centerIn: parent
                spacing: 4
                
                Image { 
                    source: "../../../../../assets/icons/calendar.svg"
                    sourceSize: Qt.size(12, 12)
                    opacity: 1.0
                    anchors.verticalCenter: parent.verticalCenter 
                }
                
                Text { 
                    text: "Now"
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#555"
                    anchors.verticalCenter: parent.verticalCenter 
                }
            }

            MouseArea {
                id: nowMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                
                onClicked: (mouse) => {
                    var d = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                    field.text = d
                    root.inputValueChanged(root.fieldKey, d)
                    mouse.accepted = true
                }
            }
        }

        // Clear button
        Rectangle {
            visible: !root.isViewOnly && field.text !== ""
            width: 20
            height: 20
            radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: clearMouseArea.containsMouse ? "#E5E7EB" : "transparent"
            
            Image { 
                anchors.centerIn: parent
                source: "../../../../../assets/icons/close.svg"
                sourceSize: Qt.size(12, 12)
                opacity: 1.0
            }
            
            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                
                onClicked: (mouse) => {
                    field.text = ""
                    root.inputValueChanged(root.fieldKey, "")
                    mouse.accepted = true
                }
            }
        }

        // Calendar picker icon
        Rectangle {
            visible: !root.isViewOnly && field.text !== ""
            width: 20
            height: 20
            radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            color: openDTArea.containsMouse ? "#E5E7EB" : "transparent"

            Image {
                anchors.centerIn: parent
                source: "../../../../../assets/icons/calendar.svg"
                sourceSize: Qt.size(12, 12)
                opacity: 0.7
            }

            MouseArea {
                id: openDTArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                onClicked: (mouse) => {
                    var parts = field.text.split(" ")
                    if (parts.length === 2) {
                        var d = parts[0].split("-")
                        var t = parts[1].split(":")
                        if (d.length === 3) {
                            root._selYear  = parseInt(d[0])
                            root._selMonth = parseInt(d[1]) - 1
                            root._selDay   = parseInt(d[2])
                        }
                        if (t.length === 3) {
                            root._selHour   = parseInt(t[0])
                            root._selMinute = parseInt(t[1])
                            root._selSecond = parseInt(t[2])
                        }
                    }
                    dtPopup.open()
                    mouse.accepted = true
                }
            }
        }

        // Time picker icon — "T" label, same pattern as calendar icon
        Rectangle {
            visible: !root.isViewOnly && field.text !== ""
            width: 20
            height: 20
            radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 56
            anchors.verticalCenter: parent.verticalCenter
            color: openTimeArea.containsMouse ? "#E5E7EB" : "transparent"
            border.color: "#888888"
            border.width: 0.75

            Text {
                anchors.centerIn: parent
                text: "T"
                font { pixelSize: 11; bold: true; family: appTheme.rethinkSansFontName }
                color: "#555"
            }

            MouseArea {
                id: openTimeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                onClicked: (mouse) => {
                    var parts = field.text.split(" ")
                    if (parts.length === 2) {
                        var t = parts[1].split(":")
                        if (t.length === 3) {
                            var h = parseInt(t[0])
                            root._selMinute = parseInt(t[1])
                            root._selSecond = parseInt(t[2])
                            if (h === 0)       { root._timeAmPm = "AM"; root._selHour = 12 }
                            else if (h < 12)   { root._timeAmPm = "AM"; root._selHour = h  }
                            else if (h === 12) { root._timeAmPm = "PM"; root._selHour = 12 }
                            else               { root._timeAmPm = "PM"; root._selHour = h - 12 }
                        }
                    }
                    timePopup.open()
                    mouse.accepted = true
                }
            }
        }
        // End icons
    }

    //DateTime Popup
    Popup {
        id: dtPopup
        width: 280
        modal: true                                      
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay                            
        x: Math.round((parent.width - width) / 2)         
        y: Math.round((parent.height - height) / 2)       

        Overlay.modal: Rectangle {                         
            color: "#66000000"
        }

        background: Rectangle {
            color: "#FFFFFF"
            radius: 12
            border.color: "#E0E0E0"
            border.width: 1
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }

        ColumnLayout {
            width: parent.width
            spacing: 8

            // Month / Year navigation
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: prevDT.containsMouse ? "#F0F0F0" : "transparent"
                    Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 18; color: "#333" }
                    MouseArea {
                        id: prevDT
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root._selMonth === 0) { root._selMonth = 11; root._selYear-- }
                            else root._selMonth--
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().monthName(root._selMonth) + " " + root._selYear
                    font { pixelSize: 13; bold: true; family: appTheme.inclusiveSansFontName }
                    color: "#1A1A1A"
                }

                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: nextDT.containsMouse ? "#F0F0F0" : "transparent"
                    Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 18; color: "#333" }
                    MouseArea {
                        id: nextDT
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root._selMonth === 11) { root._selMonth = 0; root._selYear++ }
                            else root._selMonth++
                        }
                    }
                }
            }

            // Day-of-week headers
            Grid {
                columns: 7
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                    Text {
                        width: 34; height: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                        color: "#999"
                    }
                }

                // Blank offset cells for the first day of the month
                Repeater {
                    model: root._firstDayOfMonth(root._selYear, root._selMonth)
                    Item { width: 34; height: 34 }
                }

                // Day cells
                Repeater {
                    model: root._daysInMonth(root._selYear, root._selMonth)

                    Rectangle {
                        width: 34; height: 34; radius: 17
                        property int dayNum: index + 1
                        property bool isSelected: root._selDay === dayNum
                        property bool isToday: {
                            var t = new Date()
                            return t.getFullYear() === root._selYear &&
                                   t.getMonth() === root._selMonth &&
                                   t.getDate() === dayNum
                        }
                        color: isSelected ? "#1A1A1A" : (dayHoverDT.containsMouse ? "#F0F0F0" : "transparent")
                        border.color: isToday && !isSelected ? "#AAAAAA" : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.dayNum
                            font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                            color: parent.isSelected ? "#FFFFFF" : "#1A1A1A"
                        }

                        MouseArea {
                            id: dayHoverDT
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._selDay = parent.dayNum
                                root._applyDateTime()
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEEEEE" }

            // Time
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.bottomMargin: 4

                Text {
                    text: "Time:"
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#888"
                }

                Text {
                    Layout.fillWidth: true
                    text: {
                        var hh  = String(root._selHour).padStart(2, '0')
                        var min = String(root._selMinute).padStart(2, '0')
                        var ss  = String(root._selSecond).padStart(2, '0')
                        return hh + ":" + min + ":" + ss
                    }
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#333"
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    width: 60; height: 24; radius: 12
                    color: editTimeBtn.containsMouse ? "#1A1A1A" : "#333333"
                    Text {
                        anchors.centerIn: parent
                        text: "Edit Time"
                        font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                        color: "#FFFFFF"
                    }
                    MouseArea {
                        id: editTimeBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var h = root._selHour
                            if (h === 0)       { root._timeAmPm = "AM"; root._selHour = 12 }
                            else if (h < 12)   { root._timeAmPm = "AM" }
                            else if (h === 12) { root._timeAmPm = "PM" }
                            else               { root._timeAmPm = "PM"; root._selHour = h - 12 }
                            dtPopup.close()
                            Qt.callLater(function() { timePopup.open() })
                        }
                    }
                }
            }
        }
    }

    // Time Popup
    Popup {
        id: timePopup
        width: 260
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        Overlay.modal: Rectangle { color: "#66000000" }

        background: Rectangle {
            color: "#FFFFFF"; radius: 12
            border.color: "#E0E0E0"; border.width: 1
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 }
        }

        ColumnLayout {
            width: parent.width
            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Time"
                font { pixelSize: 14; bold: true; family: appTheme.inclusiveSansFontName }
                color: "#1A1A1A"
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEEEEE" }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 4

                // Hour
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: hourUpArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∧"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: hourUpArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selHour = (root._selHour % 12) + 1
                        }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root._selHour).padStart(2, '0')
                        font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                        color: "#1A1A1A"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter; text: "hour"
                        font { pixelSize: 10; family: appTheme.rethinkSansFontName }; color: "#999"
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: hourDownArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∨"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: hourDownArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selHour = root._selHour === 1 ? 12 : root._selHour - 1
                        }
                    }
                }

                Text { text: ":"; font { pixelSize: 20; bold: true }; color: "#CCCCCC"; Layout.alignment: Qt.AlignVCenter; bottomPadding: 20 }

                // Minute
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: minUpArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∧"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: minUpArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selMinute = (root._selMinute + 1) % 60
                        }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root._selMinute).padStart(2, '0')
                        font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                        color: "#1A1A1A"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter; text: "min"
                        font { pixelSize: 10; family: appTheme.rethinkSansFontName }; color: "#999"
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: minDownArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∨"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: minDownArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selMinute = root._selMinute === 0 ? 59 : root._selMinute - 1
                        }
                    }
                }

                Text { text: ":"; font { pixelSize: 20; bold: true }; color: "#CCCCCC"; Layout.alignment: Qt.AlignVCenter; bottomPadding: 20 }

                // Second
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: secUpArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∧"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: secUpArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selSecond = (root._selSecond + 1) % 60
                        }
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: String(root._selSecond).padStart(2, '0')
                        font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                        color: "#1A1A1A"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter; text: "sec"
                        font { pixelSize: 10; family: appTheme.rethinkSansFontName }; color: "#999"
                    }
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 32; radius: 8
                        color: secDownArea.containsMouse ? "#F0F0F0" : "#FAFAFA"
                        border.color: "#E0E0E0"; border.width: 1
                        Text { anchors.centerIn: parent; text: "∨"; font.pixelSize: 14; color: "#555" }
                        MouseArea {
                            id: secDownArea
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root._selSecond = root._selSecond === 0 ? 59 : root._selSecond - 1
                        }
                    }
                }
            }

            // AM / PM
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                Rectangle {
                    width: 56; height: 30; radius: 8
                    color: root._timeAmPm === "AM" ? "#1A1A1A" : (amArea.containsMouse ? "#F0F0F0" : "#FAFAFA")
                    border.color: "#E0E0E0"; border.width: 1
                    Text {
                        anchors.centerIn: parent; text: "AM"
                        font { pixelSize: 12; bold: root._timeAmPm === "AM"; family: appTheme.rethinkSansFontName }
                        color: root._timeAmPm === "AM" ? "#FFFFFF" : "#555"
                    }
                    MouseArea {
                        id: amArea
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root._timeAmPm = "AM"
                    }
                }
                Rectangle {
                    width: 56; height: 30; radius: 8
                    color: root._timeAmPm === "PM" ? "#1A1A1A" : (pmArea.containsMouse ? "#F0F0F0" : "#FAFAFA")
                    border.color: "#E0E0E0"; border.width: 1
                    Text {
                        anchors.centerIn: parent; text: "PM"
                        font { pixelSize: 12; bold: root._timeAmPm === "PM"; family: appTheme.rethinkSansFontName }
                        color: root._timeAmPm === "PM" ? "#FFFFFF" : "#555"
                    }
                    MouseArea {
                        id: pmArea
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root._timeAmPm = "PM"
                    }
                }
            }

            // Preview
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    var h = String(root._selHour).padStart(2, '0')
                    var m = String(root._selMinute).padStart(2, '0')
                    var s = String(root._selSecond).padStart(2, '0')
                    return h + " : " + m + " : " + s + " " + root._timeAmPm
                }
                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                color: "#555"
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#EEEEEE" }

            // OK
            Rectangle {
                Layout.fillWidth: true; height: 38; radius: 8
                color: okTimeArea.containsMouse ? "#2563EB" : "#3B82F6"
                Text {
                    anchors.centerIn: parent; text: "OK"
                    font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                    color: "#FFFFFF"
                }
                MouseArea {
                    id: okTimeArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var h24 = root._selHour
                        if (root._timeAmPm === "AM") { if (h24 === 12) h24 = 0 }
                        else { if (h24 !== 12) h24 += 12 }
                        root._selHour = h24
                        root._applyDateTime()
                        if (h24 === 0)       { root._timeAmPm = "AM"; root._selHour = 12 }
                        else if (h24 < 12)   { root._timeAmPm = "AM"; root._selHour = h24 }
                        else if (h24 === 12) { root._timeAmPm = "PM"; root._selHour = 12 }
                        else                 { root._timeAmPm = "PM"; root._selHour = h24 - 12 }
                        timePopup.close()
                    }
                }
            }

            // Cancel
            Rectangle {
                Layout.fillWidth: true; height: 38; radius: 8
                color: cancelTimeArea.containsMouse ? "#F5F5F5" : "transparent"
                border.color: "#E0E0E0"; border.width: 1
                Text {
                    anchors.centerIn: parent; text: "Cancel"
                    font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                    color: "#555"
                }
                MouseArea {
                    id: cancelTimeArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: timePopup.close()
                }
            }
        }
    }
}
