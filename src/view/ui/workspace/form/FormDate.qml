import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    property string placeholderText: "YYYY-MM-DD"
    property bool isViewOnly: false
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6

    //Calendar picker state
    property int _selYear:  new Date().getFullYear()
    property int _selMonth: new Date().getMonth()
    property int _selDay:   0

    function _applyDate(y, m, d) {
        var mm = String(m + 1).padStart(2, '0')
        var dd = String(d).padStart(2, '0')
        var str = y + "-" + mm + "-" + dd
        field.text = str
        root.inputValueChanged(root.fieldKey, str)
    }

    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function _firstDayOfMonth(y, m) { return new Date(y, m, 1).getDay() }

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
        rightPadding: (!root.isViewOnly && field.text === "") ? todayBtn.width + 12 : 32
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
            id: todayBtn
            visible: !root.isViewOnly && field.text === ""
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            height: 24
            width: todayRow.implicitWidth + 16
            radius: 12
            color: todayMouseArea.containsMouse ? "#E5E7EB" : "transparent"
            
            Row {
                id: todayRow
                anchors.centerIn: parent
                spacing: 4
                
                Image { 
                    source: "../../../../../assets/icons/calendar.svg"
                    sourceSize: Qt.size(12, 12)
                    opacity: 1.0
                    anchors.verticalCenter: parent.verticalCenter 
                }
                
                Text { 
                    text: "Today"
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#555"
                    anchors.verticalCenter: parent.verticalCenter 
                }
            }

            MouseArea {
                id: todayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                
                onClicked: (mouse) => {
                    var d = Qt.formatDate(new Date(), "yyyy-MM-dd")
                    field.text = d
                    root.inputValueChanged(root.fieldKey, d)

                    mouse.accepted = true
                }
            }
        }

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

        // Calendar picker icon (visible when field has text) 
        Rectangle {
            visible: !root.isViewOnly && field.text !== ""
            width: 20
            height: 20
            radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            color: openCalArea.containsMouse ? "#E5E7EB" : "transparent"

            Image {
                anchors.centerIn: parent
                source: "../../../../../assets/icons/calendar.svg"
                sourceSize: Qt.size(12, 12)
                opacity: 0.7
            }

            MouseArea {
                id: openCalArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true

                onClicked: (mouse) => {
                    var parts = field.text.split("-")
                    if (parts.length === 3) {
                        root._selYear  = parseInt(parts[0])
                        root._selMonth = parseInt(parts[1]) - 1
                        root._selDay   = parseInt(parts[2])
                    }
                    calPopup.open()
                    mouse.accepted = true
                }
            }
        }
        //End calendar picker icon
    }

    //Calendar Popup 
    Popup {
        id: calPopup
        width: 280
        modal: true                                       // CHANGED: was false — dims background, focuses attention on picker
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        parent: Overlay.overlay                            // CHANGED: was `field` — center relative to the whole window
        x: Math.round((parent.width - width) / 2)          // CHANGED: was `x: 0`
        y: Math.round((parent.height - height) / 2)         // CHANGED: was `y: field.height + 4`

        Overlay.modal: Rectangle {                          // NEW: dim backdrop, since modal is now true
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
                    color: prevArea.containsMouse ? "#F0F0F0" : "transparent"
                    Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 18; color: "#333" }
                    MouseArea {
                        id: prevArea
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
                    color: nextArea.containsMouse ? "#F0F0F0" : "transparent"
                    Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 18; color: "#333" }
                    MouseArea {
                        id: nextArea
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
                        color: isSelected ? "#1A1A1A" : (dayHover.containsMouse ? "#F0F0F0" : "transparent")
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
                            id: dayHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root._selDay = parent.dayNum
                                root._applyDate(root._selYear, root._selMonth, parent.dayNum)
                                calPopup.close()
                            }
                        }
                    }
                }
            }

            // Today shortcut
            Rectangle {
                Layout.fillWidth: true
                height: 30
                radius: 8
                color: todayShortcutArea.containsMouse ? "#F5F5F5" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                    color: "#555"
                }

                MouseArea {
                    id: todayShortcutArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var t = new Date()
                        root._selYear  = t.getFullYear()
                        root._selMonth = t.getMonth()
                        root._selDay   = t.getDate()
                        root._applyDate(root._selYear, root._selMonth, root._selDay)
                        calPopup.close()
                    }
                }
            }
        }
    }
  
}