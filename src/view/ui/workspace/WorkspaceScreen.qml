import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: workspaceScreen
    property string currentView: "Dashboard"

    // Navigate to a related entity record — switches the nav tab and opens ViewDialog
    function navigateToRecord(entityName, recordId) {
        let name = appUtils.renameEntityName(entityName)
        appDataViewController.reselectEntity(name)
        let tabName = entityName.charAt(0).toUpperCase() + entityName.slice(1) + "s"
        workspaceScreen.currentView = tabName
        let record = appDataViewController.getRecordByKey(recordId)
        Qt.callLater(function() {
            viewDialog.entityName = entityName
            viewDialog.viewData   = record
            viewDialog.open()
        })
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // > LEFT PANE: NAVIGATION
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
                        id: newBtn
                        property bool show: workspaceScreen.currentView !== "Dashboard"

                        text: "New"
                        iconName: "add"
                        enableAnimate: true

                        enabled: show
                        Layout.preferredWidth: implicitWidth
                        Layout.preferredHeight: show ? implicitHeight : 0
                        Layout.topMargin: show ? 0 : -12

                        opacity: show ? 1.0 : 0.0
                        scale: show ? 1.0 : 0.5

                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        Behavior on Layout.topMargin { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }

                        onClicked: {
                            if (workspaceScreen.currentView !== "Dashboard") {
                                addDialog.entityName = appUtils.renameEntityName(workspaceScreen.currentView)
                                addDialog.open()
                            }
                        }
                    }

                    // >> navigation group
                    Components.NavGroup {
                        Layout.fillWidth: true
                        Layout.topMargin: 12

                        Components.NavItem {
                            text: "Dashboard"
                            iconName: "dashboard"
                            checked: workspaceScreen.currentView === "Dashboard"
                            onClicked: workspaceScreen.currentView = "Dashboard"
                        }
                        Components.NavItem {
                            text: "Units"
                            iconName: "unit"
                            checked: workspaceScreen.currentView === "Units"
                            onClicked: workspaceScreen.currentView = "Units"
                        }
                        Components.NavItem {
                            text: "Customers"
                            iconName: "customer"
                            checked: workspaceScreen.currentView === "Customers"
                            onClicked: workspaceScreen.currentView = "Customers"
                        }
                        Components.NavItem {
                            text: "Rents"
                            iconName: "rent"
                            checked: workspaceScreen.currentView === "Rents"
                            onClicked: workspaceScreen.currentView = "Rents"
                        }
                        Components.NavItem {
                            text: "Payments"
                            iconName: "payment"
                            checked: workspaceScreen.currentView === "Payments"
                            onClicked: workspaceScreen.currentView = "Payments"
                        }
                        Components.NavItem {
                            text: "Liabilities"
                            iconName: "liability"
                            checked: workspaceScreen.currentView === "Liabilities"
                            onClicked: workspaceScreen.currentView = "Liabilities"
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            // > RIGHT PANE: CONTENT AREA
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: 0
                    currentIndex: workspaceScreen.currentView === "Dashboard" ? 0 : 1

                    // >> dashboard view
                    DashboardView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onLogoutClicked: stack.pop()

                        onNavigateRequested: function(viewName) {
                            let name = appUtils.renameEntityName(viewName)
                            appDataViewController.reselectEntity(name)
                            workspaceScreen.currentView = viewName
                        }
                    }

                    // >> data view (for units, customers, rents, payments, liabilities)
                    DataView {
                        id: dataView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        activeTabName: workspaceScreen.currentView
                        onLogoutClicked: stack.pop()

                        onActiveTabNameChanged: {
                            if (activeTabName !== "Dashboard") {
                                let name = appUtils.renameEntityName(activeTabName)
                                appDataViewController.reselectEntity(name)
                            }
                        }
                    }
                }
            }
        }

        // > toast notification
        Components.Toast {
            id: appToast
        }

        // > dialogs
        ViewDialog {
            id: viewDialog
        }

        AddDialog {
            id: addDialog
            onAddClicked: function(data) {
                let result = appDataViewController.addRecord(data)
                let didFail = !result.success
                appToast.showToast(result.message, didFail)
            }
        }

        EditDialog {
            id: editDialog
            onSaveClicked: function(oldData, newData) {
                let result = appDataViewController.updateRecord(oldData, newData)
                let didFail = !result.success
                appToast.showToast(result.message, didFail)
            }
        }

        DeleteDialog {
            id: deleteDialog
            onDeleteClicked: function(oldData) {
                let result = appDataViewController.deleteRecord(oldData)
                let didFail = !result.success
                appToast.showToast(result.message, didFail)
            }
        }

        PostReturnDialog {
            id: postReturnDialog
        }
    }
}
