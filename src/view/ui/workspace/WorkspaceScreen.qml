import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: workspaceScreen

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // > navigation pane [left]
            Item {
                Layout.preferredWidth: 150
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 5
                    spacing: 12

                    // >> app logo & title
                    RowLayout {
                        spacing: 8
                        
                        Components.AppLogo {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                        }

                        Components.TitleText {
                            text: "vrooms"
                            textSize: 24
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // >> "new" button
                    Components.FloatingButton {
                        text: "New"
                        iconName: "add"
                        Layout.preferredWidth: implicitWidth 
                        enableAnimate: true
                    }

                    // >> navigation group
                    Components.NavGroup {
                        Layout.fillWidth: true 
                        Layout.topMargin: 12

                        Components.NavItem {
                            text: "Dashboard"
                            iconName: "dashboard"
                            checked: true
                        }

                        Components.NavItem {
                            text: "Units"
                            iconName: "unit"
                        }

                        Components.NavItem {
                            text: "Customers"
                            iconName: "customer"
                        }

                        Components.NavItem {
                            text: "Rents"
                            iconName: "rent"
                        }

                        Components.NavItem {
                            text: "Payments"
                            iconName: "payment"
                        }

                        Components.NavItem {
                            text: "Liabilities"
                            iconName: "liability"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            // > content pane [right]
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: 0
                    spacing: 12

                    // >> top bar
                    RowLayout {
                        Layout.fillWidth: true

                        Components.SearchBar {
                            Layout.preferredWidth: 300
                            placeholderText: "Search ..."
                        }
                        
                        Item {
                            Layout.fillWidth: true 
                        }

                        Components.PrimaryButton {
                            text: "User"
                            textSize: 13
                            iconName: "account"
                            enableAnimate: true

                            onClicked: userMenu.open()

                            Components.ContextMenu {
                                id: userMenu
                                y: parent.height + 4 + (userMenu.slideOffset !== undefined ? userMenu.slideOffset : 0)
                                x: parent.width - width

                                Components.ContextMenuItem {
                                    text: "Logout"
                                    iconName: "logout"
                                    onTriggered: stack.pop() // > go back to login screen
                                }
                            }
                        }
                    }

                    // >> tool bar
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

                        Item {
                            Layout.fillWidth: true 
                        }

                        Components.ToggleButtonGroup {
                            Components.ToggleButton {
                                iconName: "table-view"
                                checked: true
                            }
                            Components.ToggleButton {
                                iconName: "list-view" 
                            }
                            Components.ToggleButton {
                                iconName: "grid-view"
                            }
                        }
                    }

                    // >> main content area (TODO)
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

                    // >> bottom bar (TODO)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        
                        Components.InfoText {
                            text: "To Be Added"
                            textSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}