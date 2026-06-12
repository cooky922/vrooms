import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    property string placeholderText: "YYYY-MM-DD HH:MM:SS"
    property bool isViewOnly: false
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6

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
        rightPadding: (!root.isViewOnly && field.text === "") ? nowBtn.width + 12 : 32
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
            id: nowBtn
            visible: !root.isViewOnly && field.text === ""
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            height: 24
            width: nowRow.implicitWidth + 16
            radius: 12
            color: nowMouseArea.containsMouse ? "#E5E7EB" : "transparent"
            
            Row {
                id: nowRow
                anchors.centerIn: parent
                spacing: 4
                
                Image { 
                    source: "../../../../../assets/icons/calendar.svg"
                    sourceSize: Qt.size(12, 12)
                    opacity: 1.0
                    anchors.verticalCenter: parent.verticalCenter 
                }
                
                Text { 
                    text: "Now"
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#555"
                    anchors.verticalCenter: parent.verticalCenter 
                }
            }

            MouseArea {
                id: nowMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                preventStealing: true
                
                onClicked: (mouse) => {
                    var d = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
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
    }
}