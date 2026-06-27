import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../components" as Components

Item {
    id: root

    signal logoutClicked()
    signal navigateRequested(string viewName) 

    Component.onCompleted: {
        appDashboardController.refreshData()
    }

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
                onClicked: userMenu.toggle()

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

        // > dashboard main content area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            
            background: Item {}

            ColumnLayout {
                width: parent.width
                spacing: 24

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3 
                    columnSpacing: 16
                    Layout.topMargin: 12

                    component CombinedCard: Rectangle {
                        id: cardRoot
                        property string title: ""
                        property string value: "0"
                        property color bgColor: "#FFFFFF"
                        property color barColor: "#E5E7EB"
                        property string iconSource: ""
                        property string targetView: ""
                        property var modelData: []
                        property real totalValue: 1

                        Layout.fillWidth: true
                        Layout.preferredHeight: 340 
                        radius: 16 
                        color: bgColor

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#1A000000" 
                            shadowBlur: 16
                            shadowVerticalOffset: 4
                        }

                        transform: Translate {
                            y: cardMouseArea.containsMouse ? -4 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

                        MouseArea {
                            id: cardMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (cardRoot.targetView !== "") {
                                    root.navigateRequested(cardRoot.targetView)
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 16

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 24
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                spacing: 8

                                Item {
                                    Layout.preferredWidth: 42
                                    Layout.preferredHeight: 42
                                    visible: cardRoot.iconSource !== ""

                                    Image {
                                        id: cardIcon
                                        source: cardRoot.iconSource
                                        sourceSize: Qt.size(42, 42)
                                        anchors.fill: parent
                                        visible: false
                                    }

                                    MultiEffect {
                                        source: cardIcon
                                        anchors.fill: cardIcon
                                        colorizationColor: cardRoot.barColor
                                        colorization: 1.0
                                    }
                                }

                                Text {
                                    text: cardRoot.title
                                    font.pixelSize: 15
                                    font.family: appTheme.rethinkSansFontName 
                                    color: "#333333" 
                                    opacity: 0.85 
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: cardRoot.value
                                    font.pixelSize: 38
                                    font.bold: true
                                    font.family: appTheme.rethinkSansFontName 
                                    color: "#333333" 
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 2 
                                color: cardRoot.barColor
                                Layout.leftMargin: 0
                                Layout.rightMargin: 0
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                Layout.bottomMargin: 24
                                spacing: 8
                                
                                Repeater {
                                    model: cardRoot.modelData
                                    delegate: Item {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 28 

                                        Rectangle {
                                            height: parent.height
                                            width: cardRoot.totalValue > 0 ? (Number(modelData.value) / cardRoot.totalValue) * parent.width : 0
                                            color: cardRoot.barColor
                                            radius: 6
                                            Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            spacing: 12

                                            Text {
                                                text: modelData.label
                                                Layout.fillWidth: true
                                                font.pixelSize: 12
                                                font.bold: true
                                                font.family: appTheme.rethinkSansFontName
                                                color: "#333333" 
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: modelData.value
                                                font.pixelSize: 13
                                                font.bold: true
                                                font.family: appTheme.rethinkSansFontName
                                                color: "#333333"
                                            }
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true } 
                            }
                        }
                    }

                    CombinedCard { 
                        title: "Total Units"
                        value: appDashboardController.totalUnits.toString()
                        bgColor: "#E0F2FE" 
                        barColor: "#BAE6FD" 
                        iconSource: "../../../../assets/icons/unit-filled.svg"
                        targetView: "Units"
                        modelData: appDashboardController.unitsByStatusData
                        totalValue: appDashboardController.totalUnits
                    }

                    CombinedCard { 
                        title: "Total Customers"
                        value: appDashboardController.totalCustomers.toString()
                        bgColor: "#DCFCE7" 
                        barColor: "#BBF7D0" 
                        iconSource: "../../../../assets/icons/customer-filled.svg"
                        targetView: "Customers"
                        modelData: appDashboardController.customersByStatusData
                        totalValue: appDashboardController.totalCustomers
                    }

                    CombinedCard { 
                        title: "Total Rents"
                        value: appDashboardController.totalRents.toString()
                        bgColor: "#F3E8FF" 
                        barColor: "#E9D5FF" 
                        iconSource: "../../../../assets/icons/rent-filled.svg"
                        targetView: "Rents"
                        modelData: appDashboardController.rentsByStatusData
                        totalValue: appDashboardController.totalRents
                    }
                }
                
                Item { Layout.preferredHeight: 24 } 
            }
        }
    }
}