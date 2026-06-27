import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property string placeholderText: ""
    property var value: ""
    property bool isViewOnly: false
    property string errorText: ""
    property var options: []
    
    property bool canAutoFill: false

    signal inputValueChanged(string key, var val)
    signal autoFillRequested()

    onValueChanged: {
        let strVal = (root.value !== undefined && root.value !== null) ? root.value.toString() : ""
        if (field.text !== strVal) {
            field.text = strVal
        }
    }
    
    Component.onCompleted: {
        let strVal = (root.value !== undefined && root.value !== null) ? root.value.toString() : ""
        field.text = strVal
    }

    Layout.fillWidth: true
    spacing: 6

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font.pixelSize: 13
        font.family: appTheme.inclusiveSansFontName
        color: "#333333"
    }

    TextField {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        placeholderText: root.isViewOnly ? "-" : root.placeholderText
        
        leftPadding: 12
        rightPadding: (root.canAutoFill && !root.isViewOnly) ? (clearBtn.visible ? 115 : 90) : (clearBtn.visible ? 32 : 12)
        
        font.pixelSize: 12
        font.family: appTheme.rethinkSansFontName

        readOnly: root.isViewOnly
        color: root.isViewOnly ? "#666666" : "#333333"
        placeholderTextColor: "#AAAAAA"

        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: RegularExpressionValidator { regularExpression: /^-?\d*\.?\d*$/ }

        // text: root.value !== undefined ? root.value : ""
        onTextEdited: root.inputValueChanged(root.fieldKey, text)

        background: Rectangle {
            radius: 15
            color: root.isViewOnly ? "#EEEEEE" : "transparent"
            border {
                color: root.isViewOnly ? "transparent" : (root.errorText !== "" ? "#E53935" : (field.activeFocus ? appTheme.activeColor : "#888888"))
                width: field.activeFocus && !root.isViewOnly ? 2 : (root.isViewOnly ? 0 : 0.75)
            }
        }

        HoverHandler { id: hover }

        transform: Translate {
            y: (hover.hovered && !root.isViewOnly) ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        }

        Rectangle {
            id: autoFillBtn
            visible: root.canAutoFill && !root.isViewOnly
            width: autoFillContent.implicitWidth + 16
            height: 20
            radius: 10
            anchors.right: clearBtn.visible ? clearBtn.left : parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: autoFillArea.containsMouse ? "#E5E7EB" : "transparent"
            
            RowLayout {
                id: autoFillContent
                anchors.centerIn: parent
                spacing: 4
                Image { source: "../../../../../assets/icons/calculate.svg"; sourceSize: Qt.size(12, 12); opacity: 0.8 }
                Text { 
                    text: "Calculate"
                    font.pixelSize: 10
                    font.family: appTheme.rethinkSansFontName
                    color: "#555555"
                }
            }
            MouseArea {
                id: autoFillArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    field.forceActiveFocus()
                    root.autoFillRequested()
                }
            }
        }

        // --- EXISTING: CLEAR BUTTON ---
        Rectangle {
            id: clearBtn
            visible: !root.isViewOnly && field.text !== ""
            width: 20; height: 20; radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: clearMouseArea.containsMouse ? "#E5E7EB" : "transparent"
            Image { anchors.centerIn: parent; source: "../../../../../assets/icons/close.svg"; sourceSize: Qt.size(12, 12); opacity: 1.0 }
            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.inputValueChanged(root.fieldKey, "")
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