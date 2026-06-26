import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: 260
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    // --- State Properties (12-hour context for UI) ---
    property int selHour: 12
    property int selMinute: 0
    property int selSecond: 0
    property string timeAmPm: "AM"

    // --- Signal ---
    signal timeSelected(int h24, int min, int sec)

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
                        onClicked: popup.selHour = (popup.selHour % 12) + 1
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: String(popup.selHour).padStart(2, '0')
                    font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                    color: "#1A1A1A"
                }
                Text { 
                    Layout.alignment: Qt.AlignHCenter
                    text: "hour"
                    font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                    color: "#999" 
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
                        onClicked: popup.selHour = popup.selHour === 1 ? 12 : popup.selHour - 1
                    }
                }
            }

            Text { 
                text: ":"
                font { pixelSize: 20; bold: true }
                color: "#CCCCCC"
                Layout.alignment: Qt.AlignVCenter
                bottomPadding: 20 
            }

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
                        onClicked: popup.selMinute = (popup.selMinute + 1) % 60
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: String(popup.selMinute).padStart(2, '0')
                    font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                    color: "#1A1A1A"
                }
                Text { 
                    Layout.alignment: Qt.AlignHCenter
                    text: "min"
                    font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                    color: "#999" 
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
                        onClicked: popup.selMinute = popup.selMinute === 0 ? 59 : popup.selMinute - 1
                    }
                }
            }

            Text { 
                text: ":"
                font { pixelSize: 20; bold: true }
                color: "#CCCCCC"
                Layout.alignment: Qt.AlignVCenter
                bottomPadding: 20 
            }

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
                        onClicked: popup.selSecond = (popup.selSecond + 1) % 60
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: String(popup.selSecond).padStart(2, '0')
                    font { pixelSize: 22; bold: true; family: appTheme.rethinkSansFontName }
                    color: "#1A1A1A"
                }
                Text { 
                    Layout.alignment: Qt.AlignHCenter
                    text: "sec"
                    font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                    color: "#999"
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
                        onClicked: popup.selSecond = popup.selSecond === 0 ? 59 : popup.selSecond - 1
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
                color: popup.timeAmPm === "AM" ? "#1A1A1A" : (amArea.containsMouse ? "#F0F0F0" : "#FAFAFA")
                border.color: "#E0E0E0"; border.width: 1
                Text { 
                    anchors.centerIn: parent
                    text: "AM"
                    font { pixelSize: 12; bold: popup.timeAmPm === "AM"; family: appTheme.rethinkSansFontName }
                    color: popup.timeAmPm === "AM" ? "#FFFFFF" : "#555" 
                }
                MouseArea {
                    id: amArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: popup.timeAmPm = "AM"
                }
            }
            Rectangle {
                width: 56; height: 30; radius: 8
                color: popup.timeAmPm === "PM" ? "#1A1A1A" : (pmArea.containsMouse ? "#F0F0F0" : "#FAFAFA")
                border.color: "#E0E0E0"; border.width: 1
                Text { 
                    anchors.centerIn: parent
                    text: "PM"
                    font { pixelSize: 12; bold: popup.timeAmPm === "PM"; family: appTheme.rethinkSansFontName }
                    color: popup.timeAmPm === "PM" ? "#FFFFFF" : "#555" 
                }
                MouseArea {
                    id: pmArea
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: popup.timeAmPm = "PM"
                }
            }
        }

        // Preview
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: String(popup.selHour).padStart(2, '0') + " : " + String(popup.selMinute).padStart(2, '0') + " : " + String(popup.selSecond).padStart(2, '0') + " " + popup.timeAmPm
            font { pixelSize: 12; family: appTheme.rethinkSansFontName }
            color: "#555"
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#EEEEEE" }

        // OK Button (Triggers Conversion and Signal)
        Rectangle {
            Layout.fillWidth: true; height: 38; radius: 8
            color: okTimeArea.containsMouse ? "#2563EB" : "#3B82F6"
            Text { 
                anchors.centerIn: parent
                text: "OK"
                font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                color: "#FFFFFF" 
            }
            
            MouseArea {
                id: okTimeArea
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var h24 = popup.selHour
                    if (popup.timeAmPm === "AM") { if (h24 === 12) h24 = 0 }
                    else { if (h24 !== 12) h24 += 12 }
                    
                    popup.timeSelected(h24, popup.selMinute, popup.selSecond)
                    popup.close()
                }
            }
        }

        // Cancel Button
        Rectangle {
            Layout.fillWidth: true; height: 38; radius: 8
            color: cancelTimeArea.containsMouse ? "#F5F5F5" : "transparent"
            border.color: "#E0E0E0"; border.width: 1
            Text { 
                anchors.centerIn: parent
                text: "Cancel"
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#555" 
            }
            MouseArea {
                id: cancelTimeArea
                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: popup.close()
            }
        }
    }
}