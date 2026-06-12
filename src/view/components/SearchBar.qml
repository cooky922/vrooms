import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "." as Components

Item {
    id: root

    property string placeholderText: "Search..."
    property alias text: inputField.text
    property color parentBgColor: "#FFFFFF"
    
    property alias inputFocus: inputField.activeFocus

    property string entityName: appDataViewController.selectedEntityName
    property var currentSchema: appEntitySchemaMap[root.entityName] || []

    signal accepted(string query)
    signal queryChanged(string query)
    signal cleared()

    Connections {
        target: appDataViewController
        function onSelectedEntityChanged() {
            inputField.text = ""
        }
    }

    implicitWidth: 320
    implicitHeight: 30

    readonly property string _iconSourceDirectory: "../../../assets/icons/"
    readonly property bool isFilterActive: appDataViewController.searchFilterIndex !== 0 || appDataViewController.searchMatchType !== 0

    Item {
        id: container
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height

        readonly property bool isHovered: rootArea.containsMouse || clearMouseArea.containsMouse || filterMouseArea.containsMouse || inputField.hovered

        anchors.verticalCenterOffset: isHovered ? -2 : 0
        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        Rectangle {
            anchors.fill: parent
            radius: height / 2 
            color: "#ECECEC"
        }

        // > content row
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 6
            spacing: 8

            // >> search icon
            Item {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14

                scale: root.text !== "" ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                Image {
                    id: searchIcon
                    source: root._iconSourceDirectory + "search.svg"
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: searchIcon
                    anchors.fill: searchIcon
                    colorizationColor: "#888888"
                    colorization: 1.0
                }
            }

            // >> text field
            TextField {
                id: inputField
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                placeholderText: root.placeholderText
                placeholderTextColor: "#888888" 
                
                font.family: appTheme.rethinkSansFontName
                font.pixelSize: 12
                color: "#333333"
                
                background: Item {} 
                
                leftPadding: 0
                rightPadding: 0
                verticalAlignment: TextInput.AlignVCenter

                onTextChanged: {
                    root.queryChanged(text)
                    appDataViewController.updateSearch(text)
                }
                
                onAccepted: root.accepted(text)
            }

            // >> clear button
            Item {
                id: clearSection
                Layout.preferredWidth: root.text !== "" ? 20 : 0
                Layout.fillHeight: true
                clip: true 
                opacity: root.text !== "" ? 1.0 : 0.0

                Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Item {
                    width: 20
                    height: 20
                    anchors.centerIn: parent

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        
                        color: clearMouseArea.pressed ? "#CDCDCD" : (clearMouseArea.containsMouse ? "#DDDDDD" : "transparent")
                        scale: clearMouseArea.pressed ? 0.9 : 1.0
                        
                        Behavior on scale { NumberAnimation { duration: 100 } }
                    }

                    Image {
                        id: closeIcon
                        source: root._iconSourceDirectory + "close.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                        anchors.centerIn: parent
                        visible: false
                    }

                    MultiEffect {
                        source: closeIcon
                        anchors.fill: closeIcon
                        colorizationColor: "#888888"
                        colorization: 1.0
                    }

                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            inputField.text = ""
                            root.cleared()
                            appDataViewController.updateSearch("")
                            inputField.forceActiveFocus() 
                        }
                    }
                }
            }

            // >> filter button
            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: {
                        if (root.isFilterActive) return appTheme.activeColor;
                        if (filterMouseArea.pressed) return "#CDCDCD";
                        if (filterMouseArea.containsMouse) return "#DDDDDD";
                        return "transparent";
                    }
                    
                    scale: filterMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }

                Image {
                    id: filterIcon
                    source: root._iconSourceDirectory + "filter.svg"
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.centerIn: parent
                    visible: false
                }

                MultiEffect {
                    source: filterIcon
                    anchors.fill: filterIcon
                    colorizationColor: root.isFilterActive ? "#FFFFFF" : "#888888"
                    colorization: 1.0
                }

                MouseArea {
                    id: filterMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: filterMenu.toggle()
                }

                // >> search filter menu
                Components.ContextMenu {
                    id: filterMenu
                    x: -width + parent.width 
                    y: parent.height + 8
                    
                    Components.ContextMenuItem {
                        visible: root.isFilterActive
                        text: "Reset options"
                        iconName: "close"
                        onTriggered: {
                            appDataViewController.setSearchFilterIndex(0)
                            appDataViewController.setSearchMatchType(0)
                        }
                    }
                    
                    Components.ContextMenuSeparator {
                        visible: root.isFilterActive
                        Layout.fillWidth: true
                    }

                    Components.ContextMenuHeading { text: "Search by" }
                    
                    Components.ContextMenuItem {
                        text: "All fields"
                        checkable: true
                        checked: appDataViewController.searchFilterIndex === 0
                        onTriggered: appDataViewController.setSearchFilterIndex(0)
                    }
                    
                    Repeater {
                        model: root.currentSchema
                        Components.ContextMenuItem {
                            text: modelData.label
                            checkable: true
                            checked: appDataViewController.searchFilterIndex === (index + 1)
                            onTriggered: {
                                appDataViewController.setSearchFilterIndex(index + 1)
                            }
                        }
                    }
                    
                    Components.ContextMenuSeparator {
                        Layout.fillWidth: true
                    }
                    
                    Components.ContextMenuHeading { 
                        text: "Matches" 
                    }
                    
                    Components.ContextMenuItem {
                        text: "Contains"
                        shortcutText: "-Az-"
                        checkable: true
                        checked: appDataViewController.searchMatchType === 0
                        onTriggered: appDataViewController.setSearchMatchType(0)
                    }
                    Components.ContextMenuItem {
                        text: "Exactly"
                        shortcutText: "Az"
                        checkable: true
                        checked: appDataViewController.searchMatchType === 1
                        onTriggered: appDataViewController.setSearchMatchType(1)
                    }
                    Components.ContextMenuItem {
                        text: "Starts with"
                        shortcutText: "Az-"
                        checkable: true
                        checked: appDataViewController.searchMatchType === 2
                        onTriggered: appDataViewController.setSearchMatchType(2)
                    }
                    Components.ContextMenuItem {
                        text: "Ends with"
                        shortcutText: "-Az"
                        checkable: true
                        checked: appDataViewController.searchMatchType === 3
                        onTriggered: appDataViewController.setSearchMatchType(3)
                    }
                }
            }
        }
        
        MouseArea {
            id: rootArea
            anchors.fill: parent
            z: -1 
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            onClicked: inputField.forceActiveFocus()
        }
    }
}