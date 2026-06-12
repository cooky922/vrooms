import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
    
    signal inputValueChanged(string key, var val)

    Layout.fillWidth: true
    spacing: 6

    Text {
        text: root.label + (root.isRequired ? " <font color='#E53935'>*</font>" : "")
        textFormat: Text.RichText
        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
        color: "#333"
    }

    FileDialog { 
        id: imageDialog
        title: "Select File"
        nameFilters: ["Files (*.*)"]
        onAccepted: root.inputValueChanged(root.fieldKey, selectedFile)
    }

    Rectangle {
        id: fileUpload
        Layout.fillWidth: true
        height: 90
        radius: 12
        
        color: {
            if (root.value && root.value !== "") return "#C2E7FF"
            if (dropArea.containsDrag) return "#EBF3FB"
            return "transparent"
        }
        
        border.color: dropArea.containsDrag ? appTheme.activeColor : "#888888"
        border.width: (root.value && root.value !== "") ? 0 : 0.75
        
        HoverHandler { 
            id: fileHover
            cursorShape: Qt.PointingHandCursor 
        }
        
        transform: Translate { 
            y: fileHover.hovered ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } } 
        }

        Column {
            anchors.centerIn: parent
            spacing: 4
            
            Image { 
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../../../../assets/icons/upload.svg"
                sourceSize: Qt.size(28, 28)
                opacity: 0.55 
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.value && root.value !== "") ? root.value : "Browse Files"
                font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                color: "#444"
                elide: Text.ElideMiddle
                width: Math.min(implicitWidth, fileUpload.width - 32)
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Drag and Drop Files"
                font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                color: "#888"
                visible: (!root.value || root.value === "")
            }
        }

        Rectangle {
            visible: root.value && root.value !== ""
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            width: 20
            height: 20
            radius: 10
            color: clearFileMouse.containsMouse ? "#1A001D35" : "transparent"
            z: 10
            
            Image { 
                anchors.centerIn: parent
                source: "../../../../../assets/icons/close.svg"
                sourceSize: Qt.size(12, 12)
                opacity: 1.0
            }
            
            MouseArea { 
                id: clearFileMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor 
                hoverEnabled: true
                
                onClicked: (mouse) => { 
                    root.inputValueChanged(root.fieldKey, "") 
                    mouse.accepted = true
                } 
            }
        }

        DropArea { 
            id: dropArea
            anchors.fill: parent
            onDropped: (drop) => { 
                if (drop.hasUrls) {
                    root.inputValueChanged(root.fieldKey, drop.urls[0]) 
                }
            } 
        }
        
        TapHandler { 
            onTapped: imageDialog.open() 
        }
    }
}