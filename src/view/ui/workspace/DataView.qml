import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: root

    property string activeTabName: ""
    signal logoutClicked()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // > data top bar
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Components.SearchBar {
                Layout.preferredWidth: 300
                placeholderText: "Search " + root.activeTabName + "..."
            }
            
            Item { Layout.fillWidth: true }

            Components.PrimaryButton {
                text: "User"
                textSize: 13
                iconName: "account"
                enableAnimate: true
                onClicked: userMenu.open()

                Components.ContextMenu {
                    id: userMenu
                    y: parent.height - 12 + (userMenu.slideOffset !== undefined ? userMenu.slideOffset : 0)
                    x: parent.width - width + 16
                    
                    Components.ContextMenuItem {
                        text: "Logout"
                        iconName: "logout"
                        onTriggered: root.logoutClicked() 
                    }
                }
            }
        }

        // > data tool bar
        RowLayout {
            Layout.fillWidth: true

            Components.DropdownChip {
                label: "Type"
                model: ["Documents", "Spreadsheets", "PDFs"]
                isSmall: true
            }

            Components.DropdownChip {
                label: "Status"
                model: ["All", "Active", "Inactive"]
                isSmall: true
            }

            Item { Layout.fillWidth: true } // Spacer

            Components.ToggleButtonGroup {
                Components.ToggleButton { iconName: "table-view"; checked: true }
                Components.ToggleButton { iconName: "list-view" }
                Components.ToggleButton { iconName: "grid-view" }
            }
        }

        // > data main content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FFFFFF"
            radius: 6
            border {
                color: appTheme.borderColor
                width: 0.5
            }
        }

        // > data bottom bar
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            
            Components.InfoText {
                text: "Viewing " + root.activeTabName
                textSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}