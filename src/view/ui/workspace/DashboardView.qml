import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: root

    signal logoutClicked()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // > dashboard top bar
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Components.TitleText {
                text: "Dashboard"
                textSize: 22
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Components.PrimaryButton {
                text: "Test"
                textSize: 13
                enableAnimate: true
                onClicked: testMenu.toggle()

                Components.ContextMenu {
                    id: testMenu
                    y: parent.height + 3 + (testMenu.slideOffset !== undefined ? testMenu.slideOffset : 0)
                    x: -26

                    // 1. Heading - for categorization
                    Components.ContextMenuHeading { text: "Manage Unit" }

                    // 2. Standard Item
                    Components.ContextMenuItem {
                        text: "Edit Details"
                        iconName: "edit"
                        shortcutText: "Ctrl+E"
                        onTriggered: appUtils.printLog("Edit clicked")
                    }

                    // 3. Highlighted Item - useful for active states or "Starred" items
                    Components.ContextMenuItem {
                        id: checkItem
                        text: "Mark as Available"
                        checkable: true
                        onTriggered: {
                            if (checkItem.checked)
                                appUtils.printLog("Status set to unavailable")
                            else
                                appUtils.printLog("Status set to available")
                            checkItem.checked = checkItem.checked ^ true
                        }
                    }

                    // 4. Separator - for grouping
                    Components.ContextMenuSeparator {
                        Layout.fillWidth: true
                    }

                    Components.ContextMenuHeading { text: "Advanced" }

                    // 5. Item with custom text color
                    Components.ContextMenuItem {
                        text: "Delete Record"
                        iconName: "delete"
                        itemColor: "#E53935" // Red alert color
                        onTriggered: appUtils.printLog("Delete clicked")
                    }
                }
            }

            Components.PrimaryButton {
                text: "User"
                textSize: 13
                iconName: "account"
                enableAnimate: true
                onClicked: userMenu.open()

                Components.ContextMenu {
                    id: userMenu
                    y: parent.height + 6 + (userMenu.slideOffset !== undefined ? userMenu.slideOffset : 0)
                    x: parent.width - width
                    
                    Components.ContextMenuItem {
                        text: "Logout"
                        iconName: "logout"
                        onTriggered: root.logoutClicked() 
                    }
                }
            }
        }

        // > dashboard main content area (skeleton placeholders for now)
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12

            Repeater {
                model: 3
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: "#FFFFFF"
                    radius: 6
                    border.color: appTheme.borderColor
                    border.width: 0.5
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.columnSpan: 2
                color: "#FFFFFF"
                radius: 6
                border.color: appTheme.borderColor
                border.width: 0.5
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.columnSpan: 1
                color: "#FFFFFF"
                radius: 6
                border.color: appTheme.borderColor
                border.width: 0.5
            }
        }
    }
}