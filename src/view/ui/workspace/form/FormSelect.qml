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
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6
    z: 5

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
        color: "#333"
    }

    Components.DropdownChip {
        id: dropdown
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        menuWidth: dropdown.width 
        isSmall: true
        label: "Select " + root.label
        fontName: appTheme.rethinkSansFontName
        model: root.options
        selectedValue: root.value !== undefined ? root.value : ""
        
        onSelectedValueChanged: {
            if (root.value !== selectedValue) {
                root.inputValueChanged(root.fieldKey, selectedValue)
            }
        }
    }
}