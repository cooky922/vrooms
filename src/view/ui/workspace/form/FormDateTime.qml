import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Components

ColumnLayout {
    id: root
    
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    property string placeholderText: "YYYY-MM-DD HH:MM:SS"
    property bool isViewOnly: false
    property bool canAutoFill: true
    property string errorText: ""
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 4 

    // --- State Properties ---
    property bool _hasData: false
    property string _selYear: ""
    property string _selMonth: ""
    property string _selDay: ""
    property string _selHour: ""
    property string _selMin: ""
    property string _selSec: ""
    property string _selAmPm: ""

    // --- Models ---
    property var _monthModel: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    function formatReadableDateTime(val) {
        if (!val) return "";
        let parts = val.toString().split(" ");
        if (parts.length >= 2) {
            let dParts = parts[0].split("-");
            let tParts = parts[1].split(":");
            if (dParts.length === 3 && tParts.length >= 2) {
                let mIdx = parseInt(dParts[1]) - 1;
                let m = root._monthModel[mIdx >= 0 && mIdx < 12 ? mIdx : 0];
                let d = parseInt(dParts[2]).toString();

                let h24 = parseInt(tParts[0]);
                let ampm = h24 >= 12 ? "PM" : "AM";
                let h12 = h24 % 12;
                if (h12 === 0) h12 = 12;

                let min = tParts[1];
                let sec = tParts.length === 3 ? tParts[2] : "00";

                return `${dParts[0]} ${m} ${d}  ┃  ${h12}:${min}:${sec} ${ampm}`;
            }
        }
        return val;
    }

    function checkAndEmit() {
        if (root._selYear !== "" && root._selMonth !== "" && root._selDay !== "" &&
            root._selHour !== "" && root._selMin !== "" && root._selSec !== "" && root._selAmPm !== "") {
            
            let mIdx = root._monthModel.indexOf(root._selMonth) + 1;
            let mm = String(mIdx).padStart(2, '0');
            
            let h12 = parseInt(root._selHour);
            let isPM = root._selAmPm === "PM";
            let h24 = h12;
            
            if (isPM && h12 !== 12) h24 += 12;
            if (!isPM && h12 === 12) h24 = 0;
            
            let hh = String(h24).padStart(2, '0');
            let str = `${root._selYear}-${mm}-${root._selDay} ${hh}:${root._selMin}:${root._selSec}`;
            
            root.inputValueChanged(root.fieldKey, str);
        }
    }

    onValueChanged: {
        if (root.isViewOnly) return;
        
        if (!value) {
            root._hasData = false;
            root._selYear = ""; root._selMonth = ""; root._selDay = "";
            root._selHour = ""; root._selMin = ""; root._selSec = ""; root._selAmPm = "";
            return;
        }
        
        if (value.length >= 19) {
            let dtParts = value.toString().split(" ");
            let dParts = dtParts[0].split("-");
            let tParts = dtParts[1].split(":");
            
            if (dParts.length === 3 && tParts.length === 3) {
                root._selYear = dParts[0];
                root._selMonth = root._monthModel[parseInt(dParts[1]) - 1];
                root._selDay = dParts[2];
                
                let h24 = parseInt(tParts[0]);
                root._selAmPm = h24 >= 12 ? "PM" : "AM";
                let h12 = h24 % 12;
                if (h12 === 0) h12 = 12;
                
                root._selHour = String(h12).padStart(2, '0');
                root._selMin = tParts[1];
                root._selSec = tParts[2];
                
                root._hasData = true;
            }
        }
    }

    onIsViewOnlyChanged: {
        if (!isViewOnly && value && value.length >= 19) {
            let dtParts = value.toString().split(" ");
            let dParts = dtParts[0].split("-");
            let tParts = dtParts[1].split(":");
            if (dParts.length === 3 && tParts.length === 3) {
                root._selYear = dParts[0];
                root._selMonth = root._monthModel[parseInt(dParts[1]) - 1];
                root._selDay = dParts[2];
                
                let h24 = parseInt(tParts[0]);
                root._selAmPm = h24 >= 12 ? "PM" : "AM";
                let h12 = h24 % 12;
                if (h12 === 0) h12 = 12;
                
                root._selHour = String(h12).padStart(2, '0');
                root._selMin = tParts[1];
                root._selSec = tParts[2];
                
                root._hasData = true;
            }
        }
    }

    component AggregatedChip: Rectangle {
        id: chip
        property string text: ""
        signal clicked()

        Layout.preferredHeight: 20
        Layout.preferredWidth: contentText.implicitWidth + 20
        Layout.alignment: Qt.AlignVCenter
        radius: 12
        color: ma.containsMouse ? "#D1D5DB" : "#E5E7EB"
        
        transform: Translate {
            y: ma.containsMouse ? -1 : 0
            Behavior on y { NumberAnimation { duration: 100 } }
        }

        Text {
            id: contentText
            anchors.centerIn: parent
            text: chip.text
            color: "#111827"
            font.pixelSize: 11
            font.bold: true
            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                field.forceActiveFocus()
                chip.clicked()
            }
        }
    }

    // --- UI ---
    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font.pixelSize: 13 
        font.family: typeof appTheme !== "undefined" ? appTheme.inclusiveSansFontName : "sans-serif"
        color: "#333333"
    }

    // Main Container Pill
    Rectangle {
        id: field
        focus: true
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        radius: 16
        color: root.isViewOnly ? "#EEEEEE" : "transparent"
        
        border {
            color: root.isViewOnly ? "transparent" : (root.errorText !== "" ? "#E53935" : (field.activeFocus ? appTheme.activeColor : "#888888"))
            width: field.activeFocus && !root.isViewOnly ? 2 : (root.isViewOnly ? 0 : 0.75)
        }

        HoverHandler {
            id: fieldHover
            cursorShape: root.isViewOnly ? Qt.ArrowCursor : Qt.PointingHandCursor
        }

        MouseArea {
            anchors.fill: parent
            visible: !root.isViewOnly
            onClicked: field.forceActiveFocus()
            propagateComposedEvents: true 
        }

        transform: Translate {
            y: fieldHover.hovered && !root.isViewOnly ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }

        Text {
            visible: root.isViewOnly
            anchors.fill: parent
            anchors.leftMargin: 12
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
            
            color: (!root.value || root.value.toString().trim() === "") ? "#9CA3AF" : "#666666"
            text: {
                if (!root.value || root.value.toString().trim() === "") return "N/A";
                return typeof appUtils !== "undefined" ? appUtils.formatDateTime(root.value) : root.value;
            }
        }

        Loader {
            active: !root.isViewOnly
            anchors.fill: parent
            sourceComponent: Component {
                Item {
                    anchors.fill: parent

                    // Empty State (No Data)
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8
                        visible: !root._hasData

                        // Placeholder doubles as popup trigger
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.placeholderText
                                font.pixelSize: 11
                                font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                                color: maPlaceholder.containsMouse ? "#6B7280" : "#AAAAAA"
                            }

                            MouseArea {
                                id: maPlaceholder
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    field.forceActiveFocus()
                                    calLoader.active = true
                                }
                            }
                        }

                        // Now Button
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 24
                            radius: 12
                            color: nowMouseArea.containsMouse ? "#E5E7EB" : "transparent"
                            visible: root.canAutoFill
                            
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Image { source: "../../../../../assets/icons/clock.svg"; sourceSize: Qt.size(12, 12); opacity: 1.0 }
                                Text { text: "Now"; font.pixelSize: 10; font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"; color: "#555555" }
                            }
                            MouseArea {
                                id: nowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    field.forceActiveFocus()
                                    var d = new Date()
                                    root._hasData = true
                                    root._selYear = d.getFullYear().toString()
                                    root._selMonth = root._monthModel[d.getMonth()]
                                    root._selDay = String(d.getDate()).padStart(2, '0')
                                    
                                    let h = d.getHours()
                                    root._selAmPm = h >= 12 ? "PM" : "AM"
                                    let h12 = h % 12; if (h12 === 0) h12 = 12;
                                    
                                    root._selHour = String(h12).padStart(2, '0')
                                    root._selMin = String(d.getMinutes()).padStart(2, '0')
                                    root._selSec = String(d.getSeconds()).padStart(2, '0')
                                    
                                    root.checkAndEmit()
                                }
                            }
                        }
                    }

                    // Filled State (Has Data)
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 4
                        visible: root._hasData

                        // -- DATE BLOCK --
                        AggregatedChip {
                            text: `${root._selYear} ${root._selMonth} ${root._selDay}`
                            onClicked: calLoader.active = true
                        }

                        // Separator
                        Rectangle {
                            width: 2; height: 16; radius: 1
                            color: "#D1D5DB"
                            Layout.leftMargin: 4; Layout.rightMargin: 4
                        }

                        // -- TIME BLOCK --
                        AggregatedChip {
                            text: `${root._selHour}:${root._selMin}:${root._selSec} ${root._selAmPm}`
                            onClicked: timeLoader.active = true
                        }

                        Item { Layout.fillWidth: true }

                        // Clear Icon (Always Rightmost)
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: clearMouseArea.containsMouse ? "#E5E7EB" : "transparent"
                            Image { anchors.centerIn: parent; source: "../../../../../assets/icons/close.svg"; sourceSize: Qt.size(12, 12); opacity: 1.0 }
                            MouseArea {
                                id: clearMouseArea
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    field.forceActiveFocus()
                                    root._hasData = false
                                    root._selYear = ""; root._selMonth = ""; root._selDay = ""
                                    root._selHour = ""; root._selMin = ""; root._selSec = ""; root._selAmPm = ""
                                    root.inputValueChanged(root.fieldKey, "")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: calLoader
        active: false
        sourceComponent: Component {
            CalendarPopup {
                Component.onCompleted: {
                    if (root._selYear !== "") {
                        selYear = parseInt(root._selYear)
                        selMonth = root._monthModel.indexOf(root._selMonth)
                        selDay = parseInt(root._selDay)
                    }
                    open()
                }
                onDateSelected: function(year, month, day) {
                    root._selYear = year.toString()
                    root._selMonth = root._monthModel[month]
                    root._selDay = String(day).padStart(2, '0')
                    
                    if (root._selHour === "") {
                        root._selHour = "12"; root._selMin = "00"; root._selSec = "00"; root._selAmPm = "AM"
                    }
                    root._hasData = true
                    root.checkAndEmit()
                }
                onClosed: calLoader.active = false
            }
        }
    }

    // --- Lazy Loaded Clock Popup ---
    Loader {
        id: timeLoader
        active: false
        sourceComponent: Component {
            ClockPopup {
                Component.onCompleted: {
                    if (root._selHour !== "") {
                        timeAmPm = root._selAmPm
                        selHour = parseInt(root._selHour)
                        selMinute = parseInt(root._selMin)
                        selSecond = parseInt(root._selSec)
                    }
                    open()
                }
                onTimeSelected: function(h24, min, sec) {
                    root._selAmPm = h24 >= 12 ? "PM" : "AM"
                    let h12 = h24 % 12
                    if (h12 === 0) h12 = 12
                    
                    root._selHour = String(h12).padStart(2, '0')
                    root._selMin = String(min).padStart(2, '0')
                    root._selSec = String(sec).padStart(2, '0')
                    
                    if (root._selYear === "") {
                        var d = new Date()
                        root._selYear = d.getFullYear().toString()
                        root._selMonth = root._monthModel[d.getMonth()]
                        root._selDay = String(d.getDate()).padStart(2, '0')
                    }
                    root._hasData = true
                    root.checkAndEmit()
                }
                onClosed: timeLoader.active = false
            }
        }
    }
}