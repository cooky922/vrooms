import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    property string placeholderText: "YYYY-MM-DD"
    
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
        placeholderText: root.placeholderText
        leftPadding: 12
        rightPadding: field.text === "" ? todayBtn.width + 12 : 32
        font { pixelSize: 12; family: appTheme.rethinkSansFontName }
        color: "#333"
        placeholderTextColor: "#AAAAAA"
        
        text: root.value !== undefined ? root.value : ""
        onTextEdited: root.inputValueChanged(root.fieldKey, text)

        background: Rectangle {
            radius: 15
            color: "transparent"
            border.color: field.activeFocus ? appTheme.activeColor : "#888888"
            border.width: field.activeFocus ? 2 : 0.75
        }

        HoverHandler { 
            id: hover 
        }
        
        transform: Translate { 
            y: hover.hovered ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } } 
        }

        Rectangle {
            id: todayBtn
            visible: field.text === ""
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            height: 24
            width: todayRow.implicitWidth + 16
            radius: 12
            color: todayHover.hovered ? "#E5E7EB" : "transparent"
            
            Row {
                id: todayRow
                anchors.centerIn: parent
                spacing: 4
                
                Image { 
                    source: "../../../../../assets/icons/calendar.svg"
                    sourceSize: Qt.size(12, 12)
                    opacity: 1.0
                    anchors.verticalCenter: parent.verticalCenter 
                }
                
                Text { 
                    text: "Today"
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#555"
                    anchors.verticalCenter: parent.verticalCenter 
                }
            }
            
            HoverHandler { 
                id: todayHover
                cursorShape: Qt.PointingHandCursor 
            }
            
            // Fix: Multi-line formatting without semicolons
            TapHandler { 
                onTapped: {
                    var d = Qt.formatDate(new Date(), "yyyy-MM-dd")
                    field.text = d
                    root.inputValueChanged(root.fieldKey, d)
                } 
            }
        }

        Rectangle {
            visible: field.text !== ""
            width: 20
            height: 20
            radius: 10
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: clearHover.hovered ? "#E5E7EB" : "transparent"
            
            Image { 
                anchors.centerIn: parent
                source: "../../../../../assets/icons/close.svg"
                sourceSize: Qt.size(12, 12)
                opacity: 1.0
            }
            
            HoverHandler { 
                id: clearHover
                cursorShape: Qt.PointingHandCursor 
            }
            
            TapHandler { 
                onTapped: { 
                    field.text = ""
                    root.inputValueChanged(root.fieldKey, "") 
                } 
            }
        }
    }
}