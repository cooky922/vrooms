import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components
import "form" as FormElements

Popup {
    id: root

    property string entityName: ""
    property var currentSchema: appEntitySchemaMap[root.entityName] || []
    property var viewData: ({})

    anchors.centerIn: Overlay.overlay
    width: 420
    height: Math.min(implicitHeight, Overlay.overlay ? Overlay.overlay.height * 0.9 : 600)
    
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Popup.Center

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250 }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 1.0; to: 0.85; duration: 200; easing.type: Easing.InBack }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
        }
    }

    onClosed: {
        viewData = {}
        entityName = ""
    }

    Overlay.modal: Rectangle { 
        color: "#40000000" 
    }
    
    background: Rectangle { 
        color: "#FAFAFA"
        radius: 16 
    }

    contentItem: ColumnLayout {
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Image { 
                source: {
                    let entityName = appDataViewController.selectedEntityName;
                    return `../../../../assets/icons/${entityName}.svg`
                }
                sourceSize: Qt.size(24, 24)
                Layout.alignment: Qt.AlignVCenter 
                opacity: 0.8
            }
            
            Text { 
                text: "View " + appUtils.capitalize(root.entityName)
                font { pixelSize: 20; bold: true; family: appTheme.inclusiveSansFontName }
                color: "#1A1A1A"
                Layout.fillWidth: true 
            }
            
            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: closeMouseArea.containsMouse ? "#EEEEEE" : "transparent"
                
                Image { 
                    source: "../../../../assets/icons/close.svg"
                    sourceSize: Qt.size(14, 14)
                    anchors.centerIn: parent
                    opacity: 0.7 
                }

                MouseArea { 
                    id: closeMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor 
                    hoverEnabled: true
                    preventStealing: true
                    
                    onClicked: (mouse) => {
                        mouse.accepted = true
                        root.close()
                    }
                }
            }
        }

        ScrollView {
            id: formScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ColumnLayout {
                width: formScroll.availableWidth
                spacing: 16

                Repeater {
                    model: root.currentSchema
                    delegate: Loader {
                        id: fieldLoader
                        Layout.fillWidth: true
                        z: root.currentSchema.length - index 
                        asynchronous: true
                        opacity: status === Loader.Ready ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        source: {
                            switch(modelData.type) {
                                case "text": return "form/FormText.qml"
                                case "real": return "form/FormReal.qml"
                                case "int": return "form/FormInt.qml"
                                case "date": return "form/FormDate.qml"
                                case "datetime": return "form/FormDateTime.qml"
                                case "select": return "form/FormSelect.qml"
                                case "file": return "form/FormFile.qml"
                                default: return "form/FormText.qml"
                            }
                        }
                        
                        onLoaded: {
                            item.fieldKey = modelData.key
                            item.label = modelData.label
                            item.isRequired = false
                            item.isViewOnly = true 
                            
                            if (modelData.options) {
                                item.options = modelData.options
                            }
                        }

                        Binding {
                            when: fieldLoader.status === Loader.Ready
                            target: fieldLoader.item
                            property: "value"
                            value: root.viewData[modelData.key] !== undefined ? root.viewData[modelData.key] : ""
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Item { Layout.fillWidth: true }
            
            Components.PrimaryButton {
                text: "Close"
                Layout.preferredHeight: 32
                onClicked: root.close() 
            }
        }
    }
}