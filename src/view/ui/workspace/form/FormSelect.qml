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
    property string errorText: ""
    property string placeholderText: "-"

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
            model: root.options
            selectedValue: root.value !== undefined ? root.value : ""
            borderColor: root.errorText !== "" ? "#E53935" : "#888888"

            onSelectedValueChanged: {
                if (!root.isViewOnly && root.value !== selectedValue) {
                    root.inputValueChanged(root.fieldKey, selectedValue)
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
                text: (root.value !== undefined && root.value !== "") ? root.value : root.placeholderText
                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                color: "#666666"
                elide: Text.ElideRight
            }
        }
    }

    Text {
        visible: root.errorText !== ""
        text: root.errorText
        color: "#E53935"
        font { pixelSize: 11; family: appTheme.rethinkSansFontName }
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}