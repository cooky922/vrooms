import QtQuick
import QtQuick.Layouts
import "../../../components" as Components

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var options: []
    property var value: ""
    property bool isViewOnly: false

    property string dynamicOptionsSource: ""
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6
    z: 5

    property var resolvedOptions: {
        if (root.dynamicOptionsSource === "availableUnits") {
            return appDynamicOptions.getAvailableUnits()
        } else if (root.dynamicOptionsSource === "activeCustomers") {
            return appDynamicOptions.getActiveCustomers()
        }
        return root.options
    }

    // NEW: maps a stored ID (e.g. "1") back to its display label (e.g. "1 – Juan Dela Cruz")
    // Only applies to activeCustomers; everything else passes through unchanged.
    function _labelForValue(val) {
        if (root.dynamicOptionsSource !== "activeCustomers") return val
        if (val === undefined || val === "") return val
        for (let i = 0; i < root.resolvedOptions.length; i++) {
            if (root.resolvedOptions[i].split(" – ")[0] === String(val)) {
                return root.resolvedOptions[i]
            }
        }
        return val  // fallback: e.g. customer no longer Active, ID not in current list
    }

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
        color: "#333"
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        Components.DropdownChip {
            id: dropdown
            visible: !root.isViewOnly
            anchors.fill: parent
            menuWidth: dropdown.width 
            isSmall: true
            label: "Select " + root.label
            fontName: appTheme.rethinkSansFontName
            model: root.resolvedOptions   // CHANGED: was root.options
            selectedValue: root._labelForValue(root.value !== undefined ? root.value : "")  // CHANGED: maps ID -> label for display

            onSelectedValueChanged: {
                if (root.isViewOnly) return

                var emitValue = selectedValue
                if (root.dynamicOptionsSource === "activeCustomers" && selectedValue !== "") {
                    emitValue = selectedValue.split(" – ")[0]   // CHANGED: strip label back down to plain customerID
                }

                if (root.value !== emitValue) {
                    root.inputValueChanged(root.fieldKey, emitValue)
                }
            }
        }

        Rectangle {
            visible: root.isViewOnly
            anchors.fill: parent
            radius: 15
            color: "#EEEEEE"
            border.width: 0
            
            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: Text.AlignVCenter
                
                text: root._labelForValue((root.value !== undefined && root.value !== "") ? root.value : "-")  // CHANGED: also show resolved label in view-only mode
                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                color: "#666666"
                elide: Text.ElideRight
            }
        }
    }
}