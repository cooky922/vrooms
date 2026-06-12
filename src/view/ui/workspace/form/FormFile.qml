import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects

ColumnLayout {
    id: root
    property string fieldKey: ""
    property string label: ""
    property bool isRequired: false
    property var value: ""
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

    FileDialog { 
        id: imageDialog
        title: "Select File"
        nameFilters: ["Files (*.*)"]
        onAccepted: {
            if (!root.isViewOnly) {
                root.inputValueChanged(root.fieldKey, selectedFile)
            }
        }
    }

    Rectangle {
        id: fileUpload
        Layout.fillWidth: true
        Layout.preferredHeight: {
            if (root.isViewOnly && root.value && root.value !== "" && previewImage.status === Image.Ready) {
                let sW = previewImage.implicitWidth
                let sH = previewImage.implicitHeight
                if (sW > 0 && fileUpload.width > 0) {
                    return Math.max(90, (fileUpload.width / sW) * sH)
                }
            }
            return 90
        }
        
        radius: 12
        
        color: {
            if (root.isViewOnly) return "#EEEEEE"
            if (root.value && root.value !== "") return "#C2E7FF"
            if (dropArea.containsDrag && !root.isViewOnly) return "#EBF3FB"
            return "transparent"
        }
        
        border.color: root.isViewOnly ? "transparent" : (dropArea.containsDrag ? appTheme.activeColor : "#888888")
        border.width: (root.isViewOnly || (root.value && root.value !== "")) ? 0 : 0.75
        
        HoverHandler { 
            id: fileHover
            cursorShape: root.isViewOnly ? Qt.ArrowCursor : Qt.PointingHandCursor 
        }
        
        transform: Translate { 
            y: (fileHover.hovered && !root.isViewOnly) ? -2 : 0
            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } } 
        }

        Rectangle {
            id: maskRect
            anchors.fill: parent
            radius: 12
            visible: false
            layer.enabled: true
        }

        Item {
            anchors.fill: parent
            visible: root.isViewOnly && root.value && root.value !== "" && previewImage.status === Image.Ready

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskRect
            }

            Image {
                id: previewImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop 
                
                source: {
                    if (!root.isViewOnly || !root.value || root.value === "") return ""
                    
                    let path = root.value.toString()
                    
                    if (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("file://")) {
                        return path
                    }
                    
                    return "file:///" + path.replace(/\\/g, "/")
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 24
                color: "#B3000000"
                
                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    text: root.value ? root.value.toString() : ""
                    font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                    color: "#FFFFFF"
                    elide: Text.ElideMiddle
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 4
            visible: root.isViewOnly && (!root.value || root.value === "" || previewImage.status === Image.Error || previewImage.status === Image.Null)
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (!root.value || root.value === "") ? "No image attached" : "Image failed to load"
                font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                color: "#666"
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.isViewOnly && root.value && root.value !== "" && previewImage.status === Image.Loading
            text: "Loading image..."
            font { pixelSize: 12; family: appTheme.rethinkSansFontName }
            color: "#888"
        }

        Column {
            anchors.centerIn: parent
            spacing: 4
            visible: !root.isViewOnly
            
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
            visible: !root.isViewOnly && root.value && root.value !== ""
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
            enabled: !root.isViewOnly
            onDropped: (drop) => { 
                if (drop.hasUrls && !root.isViewOnly) {
                    root.inputValueChanged(root.fieldKey, drop.urls[0]) 
                }
            } 
        }
        
        TapHandler { 
            enabled: !root.isViewOnly
            onTapped: imageDialog.open() 
        }
    }
}