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