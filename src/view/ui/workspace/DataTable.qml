import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Rectangle {
    id: root
    color: "transparent"

    property int hoveredRowIndex: -1

    signal editRowRequested(int rowIndex)
    signal deleteRowRequested(int rowIndex)

    Connections {
        target: appDataViewController
        function onSelectedEntityChanged() {
            tableView.contentX = 0
            tableView.contentY = 0
            tableView.forceLayout()
            header.forceLayout()
        }
    }

    ScrollBar {
        id: mainVBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: 10
        policy: ScrollBar.AsNeeded
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: mainVBar.visible ? mainVBar.width : 0
        spacing: 0

        // > left side: scrollable data area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // >> table header
            HorizontalHeaderView {
                id: header
                syncView: tableView
                boundsBehavior: Flickable.StopAtBounds
                resizableColumns: false
                clip: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                model: appDataViewController.selectedEntityTransformedModel

                delegate: Item {
                    implicitHeight: 30

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 8
                        color: headerHover.hovered || headerTap.pressed ? "#F3F4F6" : "transparent"
                        scale: headerTap.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                        Row {
                            id: headerContent
                            spacing: 8
                            anchors.fill: parent
                            transform: Translate {
                                y: headerHover.hovered && !headerTap.pressed ? -1 : 0
                                Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                            }

                            Text {
                                leftPadding: 16
                                text: (modelData && modelData.display_name) ? modelData.display_name : ""
                                font.bold: true
                                font.pixelSize: 12
                                font.family: appTheme.rethinkSansFontName
                                color: "#888888"
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 20; height: 20
                                radius: 6
                                anchors.verticalCenter: parent.verticalCenter
                                color: appTheme.activeColor
                                visible: appDataViewController.sortFieldIndex === index

                                Image {
                                    anchors.centerIn: parent
                                    source: "../../../../assets/icons/down.svg"
                                    sourceSize: Qt.size(14, 14)
                                    opacity: 0.9
                                    transformOrigin: Item.Center
                                    rotation: appDataViewController.sortAscending ? 180 : 0
                                }
                            }
                        }
                    }

                    HoverHandler { id: headerHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { id: headerTap; onTapped: appDataViewController.toggleSort(index) }
                }
            }

            // >> bottom border below header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#D1D5DB"
            }

            // >> table body
            TableView {
                id: tableView
                model: appDataTableModel
                clip: true
                columnSpacing: 0
                rowSpacing: 0
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.horizontal: ScrollBar { }
                ScrollBar.vertical: mainVBar
                Layout.fillWidth: true
                Layout.fillHeight: true

                columnWidthProvider: function(column) {
                    let entityName = appDataViewController.selectedEntityName
                    let contentWidth = appDataTableModel.getColumnWidth(column, entityName)
                    if (column === tableView.columns - 1) {
                        let usedSpace = 0
                        for (let i = 0; i < tableView.columns - 1; i++)
                            usedSpace += appDataTableModel.getColumnWidth(i, entityName)
                        let remainingSpace = tableView.width - usedSpace
                        return Math.max(contentWidth, remainingSpace)
                    }
                    return contentWidth
                }

                onWidthChanged: forceLayout()

                Connections {
                    target: appDataTableModel
                    function onModelReset() { Qt.callLater(tableView.forceLayout) }
                }

                delegate: Rectangle {
                    implicitHeight: 30
                    color: root.hoveredRowIndex === row ? "#F3F4F6" : "white"

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                        onHoveredChanged: {
                            if (hovered) root.hoveredRowIndex = row
                            else if (root.hoveredRowIndex === row) root.hoveredRowIndex = -1
                        }
                    }

                    TapHandler {
                        onTapped: {
                            viewDialog.entityName = appDataViewController.selectedEntityName
                            viewDialog.viewData = appDataTableModel.getRowData(row)
                            viewDialog.open()
                        }
                    }

                    Rectangle {
                        width: parent.width; height: 1
                        anchors.bottom: parent.bottom
                        color: "#E5E7EB"
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 20; anchors.rightMargin: 10
                        anchors.topMargin: 10; anchors.bottomMargin: 10
                        verticalAlignment: Text.AlignVCenter
                        text: (model.display) ? model.display : "None"
                        font.family: appTheme.rethinkSansFontName
                        font.pixelSize: 12
                        color: (model.display) ? "#333333" : "#808080"
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // > right side: fixed action buttons
        ColumnLayout {
            Layout.preferredWidth: 40
            Layout.fillHeight: true
            spacing: 0

            // >> sort button area
            Rectangle {
                id: sortButtonArea
                Layout.fillWidth: true
                Layout.preferredHeight: header.height
                color: "white"

                Rectangle {
                    width: 28; height: 28; radius: 14
                    anchors.centerIn: parent
                    color: rightSortHover.hovered || rightSortTap.pressed ? "#F3F4F6" : "transparent"
                    scale: rightSortTap.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Image {
                        anchors.centerIn: parent
                        source: "../../../../assets/icons/sort.svg"
                        sourceSize: Qt.size(16, 16)
                        opacity: 0.7
                    }

                    HoverHandler { id: rightSortHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        id: rightSortTap
                        onTapped: sortMenu.toggle()
                    }

                    Components.ContextMenu {
                        id: sortMenu
                        y: sortButtonArea.height + sortMenu.slideOffset
                        x: sortButtonArea.width - sortMenu.width
                        maximumHeight: 350

                        property string entityName: appDataViewController.selectedEntityName
                        property var currentSchema: appEntitySchemaMap[sortMenu.entityName]

                        Components.ContextMenuHeading {
                            text: "Sort by"
                        }

                        Repeater {
                            model: sortMenu.currentSchema
                            
                            Components.ContextMenuItem {
                                text: modelData.label 
                                checkable: true
                                checked: appDataViewController.sortFieldIndex === index 
                                
                                onTriggered: {
                                    appDataViewController.setSortOptions(index, appDataViewController.sortAscending)
                                }
                            }
                        }

                        Components.ContextMenuSeparator {
                            Layout.fillWidth: true
                        }

                        Components.ContextMenuHeading { 
                            text: "Sort order" 
                        }

                        Components.ContextMenuItem {
                            text: "Ascending"
                            checkable: true
                            checked: appDataViewController.sortAscending === true 
                            
                            onTriggered: {
                                appDataViewController.setSortOptions(appDataViewController.sortFieldIndex, true)
                            }
                        }

                        Components.ContextMenuItem {
                            text: "Descending"
                            checkable: true
                            checked: appDataViewController.sortAscending === false 
                            
                            onTriggered: {
                                appDataViewController.setSortOptions(appDataViewController.sortFieldIndex, false)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#D1D5DB"
            }

            // >> synchronized action list
            ListView {
                id: actionList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appDataTableModel
                clip: true
                interactive: false
                contentY: tableView.contentY
                Layout.bottomMargin: (tableView.ScrollBar.horizontal && tableView.ScrollBar.horizontal.visible)
                                     ? tableView.ScrollBar.horizontal.height : 0

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 30
                    color: root.hoveredRowIndex === index ? "#F3F4F6" : "white"

                    HoverHandler {
                        cursorShape: Qt.ArrowCursor
                        onHoveredChanged: {
                            if (hovered) root.hoveredRowIndex = index
                            else if (root.hoveredRowIndex === index) root.hoveredRowIndex = -1
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: "#E5E7EB"
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        anchors.centerIn: parent
                        color: moreHover.hovered || moreTap.pressed ? "#E5E7EB" : "transparent"
                        scale: moreTap.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Image {
                            anchors.centerIn: parent
                            source: "../../../../assets/icons/more.svg"
                            sourceSize: Qt.size(16, 16)
                            opacity: 0.7
                        }

                        HoverHandler { 
                            id: moreHover
                            cursorShape: Qt.PointingHandCursor 
                        }

                        TapHandler { 
                            id: moreTap
                            onTapped: rowMenu.toggle()
                        }

                        Components.ContextMenu {
                            id: rowMenu
                            // y: 3 + (rowMenu.slideOffset !== undefined ? rowMenu.slideOffset : 0)
                            x: parent.width - width + 6
                            smartPositioning: true
                            
                            Components.ContextMenuItem {
                                text: "Edit"
                                iconName: "edit"
                                onTriggered: {
                                    rowMenu.close()
                                    root.editRowRequested(index)
                                }
                            }

                            Components.ContextMenuItem {
                                text: "Delete"
                                iconName: "delete"
                                itemColor: "#EF4444"
                                onTriggered: {
                                    rowMenu.close()
                                    root.deleteRowRequested(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
