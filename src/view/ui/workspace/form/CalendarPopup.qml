import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: 280
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    // --- State Properties ---
    property int selYear: new Date().getFullYear()
    property int selMonth: new Date().getMonth()
    property int selDay: 0
    property bool _showYearPicker: false

    // --- Signal ---
    signal dateSelected(int year, int month, int day)

    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function firstDayOfMonth(y, m) { return new Date(y, m, 1).getDay() }

    onClosed: popup._showYearPicker = false

    Overlay.modal: Rectangle { color: "#66000000" }

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
                visible: !popup._showYearPicker
                color: prevArea.containsMouse ? "#F0F0F0" : "transparent"
                Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 18; color: "#333" }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.selMonth === 0) { popup.selMonth = 11; popup.selYear-- }
                        else popup.selMonth--
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                height: 28

                Text {
                    id: headerText
                    anchors.centerIn: parent
                    text: popup._showYearPicker ? "Year" : Qt.locale().monthName(popup.selMonth) + " " + popup.selYear
                    font { pixelSize: 13; bold: true; family: appTheme.inclusiveSansFontName }
                    color: "#1A1A1A"
                }

                MouseArea {
                    id: yearHitArea
                    width: 38
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: (parent.width - headerText.implicitWidth) / 2
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: popup._showYearPicker = !popup._showYearPicker
                }
            }

            Rectangle {
                width: 28; height: 28; radius: 14
                visible: !popup._showYearPicker
                color: nextArea.containsMouse ? "#F0F0F0" : "transparent"
                Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 18; color: "#333" }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (popup.selMonth === 11) { popup.selMonth = 0; popup.selYear++ }
                        else popup.selMonth++
                    }
                }
            }
        }

        // Year picker
        Item {
            id: yearPickerContainer
            visible: popup._showYearPicker
            Layout.fillWidth: true
            height: 220 

            property int rangeStart: new Date().getFullYear() - 20
            property int rangeEnd:   new Date().getFullYear() + 10

            ListView {
                id: yearList
                anchors.fill: parent
                clip: true
                model: yearPickerContainer.rangeEnd - yearPickerContainer.rangeStart + 1
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                Component.onCompleted: {
                    var idx = popup.selYear - yearPickerContainer.rangeStart
                    if (idx >= 0) yearList.positionViewAtIndex(idx, ListView.Center)
                }
                onVisibleChanged: {
                    if (visible) {
                        var idx = popup.selYear - yearPickerContainer.rangeStart
                        if (idx >= 0) yearList.positionViewAtIndex(idx, ListView.Center)
                    }
                }

                delegate: Item {
                    width: yearList.width
                    height: 40
                    property int yr: yearPickerContainer.rangeStart + index
                    property bool isCurrent: yr === popup.selYear
                    property bool isNear: Math.abs(yr - popup.selYear) <= 1

                    Text {
                        anchors.centerIn: parent
                        text: parent.yr
                        font { pixelSize: parent.isCurrent ? 20 : (parent.isNear ? 15 : 13); bold: parent.isCurrent; family: appTheme.rethinkSansFontName }
                        color: parent.isCurrent ? "#1A1A1A" : (parent.isNear ? "#555555" : "#AAAAAA")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.selYear = parent.yr
                            popup._showYearPicker = false
                        }
                    }
                }
            }
        }

        // Day-of-week headers
        Grid {
            columns: 7
            Layout.fillWidth: true
            spacing: 2
            visible: !popup._showYearPicker

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

            Repeater {
                model: popup.firstDayOfMonth(popup.selYear, popup.selMonth)
                Item { width: 34; height: 34 }
            }

            // Day cells
            Repeater {
                model: popup.daysInMonth(popup.selYear, popup.selMonth)
                Rectangle {
                    width: 34; height: 34; radius: 17
                    property int dayNum: index + 1
                    property bool isSelected: popup.selDay === dayNum
                    property bool isToday: {
                        var t = new Date()
                        return t.getFullYear() === popup.selYear && t.getMonth() === popup.selMonth && t.getDate() === dayNum
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
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            popup.selDay = parent.dayNum
                            popup.dateSelected(popup.selYear, popup.selMonth, parent.dayNum)
                            popup.close()
                        }
                    }
                }
            }
        }

        // Today shortcut
        Rectangle {
            Layout.fillWidth: true
            height: 30; radius: 8
            visible: !popup._showYearPicker
            color: todayShortcutArea.containsMouse ? "#F5F5F5" : "transparent"

            Text { 
                anchors.centerIn: parent
                text: "Today"
                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                color: "#555" 
            }
            
            MouseArea {
                id: todayShortcutArea
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var t = new Date()
                    popup.selYear = t.getFullYear()
                    popup.selMonth = t.getMonth()
                    popup.selDay = t.getDate()
                    popup.dateSelected(popup.selYear, popup.selMonth, popup.selDay)
                    popup.close()
                }
            }
        }
    }
}