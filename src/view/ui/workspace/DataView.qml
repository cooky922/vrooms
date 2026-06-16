import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: root

    property string activeTabName: ""
    property bool isGridView: false
    signal logoutClicked()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // > data top bar
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Components.SearchBar {
                Layout.preferredWidth: 350
                placeholderText: "Search " + root.activeTabName.toLowerCase() + "..."
                text: appDataViewController.searchText
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

        // > data tool bar
        RowLayout {
            Layout.fillWidth: true

            Repeater {
                model: {
                    if (root.activeTabName === "") return []
                    let entityName = appDataViewController.selectedEntityName
                    let currentSchema = appEntitySchemaMap[entityName] || []
                    return currentSchema.filter(
                        f => f.type === "select" && f.options && f.options.length > 0
                    )
                }
                
                delegate: Components.DropdownChip {
                    label: modelData.label
                    model: modelData.options
                    isSmall: true
                    
                    onSelectedValueChanged: {
                        appDataViewController.setFilterOption(modelData.key, selectedValue)
                    }

                    Connections {
                        target: root
                        function onActiveTabNameChanged() {
                            selectedValue = ""
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Components.ToggleButtonGroup {
                Components.ToggleButton { 
                    iconName: "list-view"
                    checked: !root.isGridView
                    checkable: false
                    onPressed: root.isGridView = false
                }
                Components.ToggleButton { 
                    iconName: "grid-view"
                    checked: root.isGridView
                    checkable: false
                    onPressed: root.isGridView = true
                }
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
            clip: true

            // >> list view
            DataTable {
                id: dataTable
                anchors.fill: parent
                anchors.margins: 5
                visible: !root.isGridView && appDataViewController.totalItemCount > 0

                onEditRowRequested: function(rowIndex) {
                    let rowData = appDataTableModel.getRowData(rowIndex)
                    editDialog.entityName = appDataViewController.selectedEntityName
                    editDialog.oldData = rowData
                    editDialog.open()
                }

                onDeleteRowRequested: function(rowIndex) {
                    deleteDialog.entityName = appDataViewController.selectedEntityName
                    deleteDialog.oldData = appDataTableModel.getRowData(rowIndex)
                    deleteDialog.open()
                }
            }

            // >> grid view (all entities)
            DataGridView {
                id: entityGridView
                anchors.fill: parent
                visible: root.isGridView && appDataViewController.totalItemCount > 0

                onEditRowRequested: function(rowIndex) {
                    let rowData = appDataTableModel.getRowData(rowIndex)
                    editDialog.entityName = appDataViewController.selectedEntityName
                    editDialog.oldData = rowData
                    editDialog.open()
                }

                onDeleteRowRequested: function(rowIndex) {
                    deleteDialog.entityName = appDataViewController.selectedEntityName
                    deleteDialog.oldData = appDataTableModel.getRowData(rowIndex)
                    deleteDialog.open()
                }
            }

            Components.InfoText {
                text: "No " + root.activeTabName.toLowerCase() + " found :("
                textSize: 30
                textColor: "#888888"
                anchors.centerIn: parent
                visible: appDataViewController.totalItemCount === 0
            }
        }

        // > data bottom bar
        PaginationArea {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
        }
    }
}
