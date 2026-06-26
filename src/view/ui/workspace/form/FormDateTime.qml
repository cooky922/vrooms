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
    property var _yearModel: []
    property var _monthModel: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property var _dayModel: []
    property var _hourModel: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    property var _minSecModel: []
    property var _ampmModel: ["AM", "PM"]

    Component.onCompleted: {
        if (root.isViewOnly) return; 
        let y = []
        let currY = new Date().getFullYear()
        for (let i = currY - 10; i <= currY + 15; i++) y.push(i.toString())
        root._yearModel = y

        let ms = []
        for (let i = 0; i < 60; i++) ms.push(i.toString().padStart(2, '0'))
        root._minSecModel = ms
    }

    on_SelYearChanged: root.updateDayModel()
    on_SelMonthChanged: root.updateDayModel()

    function updateDayModel() {
        if (!root._hasData || root.isViewOnly) return;
        
        var y = parseInt(root._selYear);
        if (isNaN(y)) y = new Date().getFullYear();
        
        var mIdx = root._monthModel.indexOf(root._selMonth);
        if (mIdx === -1) mIdx = 0;
        
        var days = new Date(y, mIdx + 1, 0).getDate();
        
        var arr = [];
        for (var i = 1; i <= days; i++) arr.push(String(i).padStart(2, '0'));
        root._dayModel = arr;
        
        var currentD = parseInt(root._selDay);
        if (!isNaN(currentD) && currentD > days) {
            root._selDay = String(days).padStart(2, '0');
            root.checkAndEmit();
        }
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
                root.updateDayModel();
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
                root.updateDayModel();
            }
        }
    }

    component MenuSelector: Rectangle {
        id: selRoot
        property string placeholder: ""
        property string currentValue: ""
        property var modelItems: []
        property real targetWidth: 32
        signal selected(string val)

        Layout.preferredWidth: targetWidth
        Layout.preferredHeight: 24
        Layout.alignment: Qt.AlignVCenter
        radius: 6
        color: ma.containsMouse ? "#D1D5DB" : "#E5E7EB"
        
        transform: Translate {
            y: ma.containsMouse ? -1 : 0
            Behavior on y { NumberAnimation { duration: 100 } }
        }

        Text {
            anchors.centerIn: parent
            text: selRoot.currentValue === "" ? selRoot.placeholder : selRoot.currentValue
            color: selRoot.currentValue === "" ? "#6B7280" : "#111827"
            font.pixelSize: 11
            font.bold: selRoot.currentValue !== ""
            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                cmenuLoader.active = true
                field.forceActiveFocus()
            }
        }

        Loader {
            id: cmenuLoader
            active: false
            onLoaded: item.toggle()
            sourceComponent: Component {
                Components.ContextMenu {
                    y: selRoot.height + 4
                    onClosed: cmenuLoader.active = false
                    
                    Repeater {
                        model: selRoot.modelItems
                        Components.ContextMenuItem {
                            text: modelData
                            onTriggered: { 
                                selRoot.selected(modelData)
                                close() 
                            }
                        }
                    }
                }
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
            
            // Set text to "N/A" and make it a lighter gray if it's empty
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

                        Text {
                            Layout.fillWidth: true
                            text: root.placeholderText
                            font.pixelSize: 11
                            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                            color: "#AAAAAA"
                        }

                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 24
                            radius: 12
                            color: nowMouseArea.containsMouse ? "#E5E7EB" : "transparent"
                            
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

                        // -- DATE --
                        MenuSelector { targetWidth: 40; placeholder: "YYYY"; currentValue: root._selYear; modelItems: root._yearModel; onSelected: function(val) { root._selYear = val; root.checkAndEmit(); } }
                        MenuSelector { targetWidth: 38; placeholder: "MMM";  currentValue: root._selMonth; modelItems: root._monthModel; onSelected: function(val) { root._selMonth = val; root.checkAndEmit(); } }
                        MenuSelector { targetWidth: 26; placeholder: "DD";   currentValue: root._selDay; modelItems: root._dayModel; onSelected: function(val) { root._selDay = val; root.checkAndEmit(); } }

                        // Thicker visual separator
                        Rectangle {
                            width: 2
                            height: 16
                            radius: 1
                            color: "#D1D5DB"
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                        }

                        // -- TIME --
                        MenuSelector { targetWidth: 24; placeholder: "HH"; currentValue: root._selHour; modelItems: root._hourModel; onSelected: function(val) { root._selHour = val; root.checkAndEmit(); } }
                        Text { text: ":"; font.pixelSize: 11; font.bold: true; color: "#9CA3AF" }
                        MenuSelector { targetWidth: 24; placeholder: "MM"; currentValue: root._selMin; modelItems: root._minSecModel; onSelected: function(val) { root._selMin = val; root.checkAndEmit(); } }
                        Text { text: ":"; font.pixelSize: 11; font.bold: true; color: "#9CA3AF" }
                        MenuSelector { targetWidth: 24; placeholder: "SS"; currentValue: root._selSec; modelItems: root._minSecModel; onSelected: function(val) { root._selSec = val; root.checkAndEmit(); } }
                        MenuSelector { targetWidth: 32; placeholder: "--"; currentValue: root._selAmPm; modelItems: root._ampmModel; onSelected: function(val) { root._selAmPm = val; root.checkAndEmit(); } }

                        Item { Layout.fillWidth: true }

                        // Calendar Popup Icon
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: openCalArea.containsMouse ? "#E5E7EB" : "transparent"
                            Image { anchors.centerIn: parent; source: "../../../../../assets/icons/calendar.svg"; sourceSize: Qt.size(12, 12); opacity: 0.7 }
                            MouseArea {
                                id: openCalArea
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { field.forceActiveFocus(); calLoader.active = true }
                            }
                        }

                        // Time Popup Icon (clock.svg)
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: openTimeArea.containsMouse ? "#E5E7EB" : "transparent"
                            Image { anchors.centerIn: parent; source: "../../../../../assets/icons/clock.svg"; sourceSize: Qt.size(12, 12); opacity: 0.7 }
                            MouseArea {
                                id: openTimeArea
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { field.forceActiveFocus(); timeLoader.active = true }
                            }
                        }

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

    // --- Lazy Loaded Calendar Popup ---
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