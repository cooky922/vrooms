import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components" as Components

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property string placeholderText: "Select an option..."
    property var value: ""
    property bool isViewOnly: false
    property string errorText: ""
    property var options: []

    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6
    z: 5

    // Safely extract text and values from dynamicOptions dictionary elements
    function getDisplayText(item) {
        if (item === null || item === undefined) return ""
        if (typeof item === 'object' && item.text !== undefined) return item.text.toString()
        return item.toString()
    }

    function getValue(item) {
        if (item === null || item === undefined) return ""
        if (typeof item === 'object' && item.value !== undefined) return item.value
        return item
    }

    // Resolves current display text based on active ID
    function getCurrentText() {
        if (root.value === undefined || root.value === "") return ""
        for (let i = 0; i < root.options.length; i++) {
            let v = getValue(root.options[i])
            if (v === root.value || v.toString() === root.value.toString()) {
                return getDisplayText(root.options[i])
            }
        }
        // Fallback to raw value if options haven't loaded
        return root.value.toString()
    }

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font.pixelSize: 13
        font.family: appTheme.inclusiveSansFontName
        color: "#333333"
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        TextField {
            id: field
            anchors.fill: parent
            placeholderText: root.isViewOnly ? "-" : root.placeholderText
            
            leftPadding: 12
            rightPadding: 32
            
            font.pixelSize: 12
            font.family: appTheme.rethinkSansFontName

            readOnly: true
            color: root.isViewOnly ? "#666666" : "#333333"
            placeholderTextColor: "#AAAAAA"

            text: root.getCurrentText()

            background: Rectangle {
                radius: 15
                color: root.isViewOnly ? "#EEEEEE" : "transparent"
                border {
                    color: root.isViewOnly ? "transparent" : (root.errorText !== "" ? "#E53935" : (fieldMenu.visible ? appTheme.activeColor : "#888888"))
                    width: (fieldMenu.visible && !root.isViewOnly) ? 2 : (root.isViewOnly ? 0 : 0.75)
                }
            }

            // Dropdown Icon Chevron
            Image {
                source: "../../../../../assets/icons/down.svg"
                sourceSize: Qt.size(14, 14)
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                opacity: root.isViewOnly ? 0.0 : 0.6
                visible: !root.isViewOnly
                rotation: fieldMenu.visible ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            }

            // Click Area to toggle the Context Menu
            MouseArea {
                anchors.fill: parent
                visible: !root.isViewOnly
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.options.length > 0) {
                        fieldMenu.toggle()
                    } else {
                        appToast.showToast("No available options right now.", true)
                    }
                }
            }
            
            Components.ContextMenu {
                id: fieldMenu
                y: field.height + 4
                width: field.width
                maximumHeight: 250 // Enable scrolling for long option lists

                Repeater {
                    model: root.options
                    Components.ContextMenuItem {
                        text: root.getDisplayText(modelData)
                        checkable: true
                        checked: root.value.toString() === root.getValue(modelData).toString()
                        
                        onTriggered: {
                            let selectedVal = root.getValue(modelData)
                            if (root.value !== selectedVal) {
                                root.inputValueChanged(root.fieldKey, selectedVal)
                            }
                            fieldMenu.close()
                        }
                    }
                }
            }
        }
    }

    Text {
        visible: root.errorText !== ""
        text: root.errorText
        color: "#E53935"
        font.pixelSize: 11
        font.family: appTheme.rethinkSansFontName
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}