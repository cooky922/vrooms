import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "transparent"

    Connections {
        target: appDataViewController
        function onSelectedEntityChanged() {
            tableView.forceLayout()
            header.forceLayout()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // > Table Header
        HorizontalHeaderView {
            id: header
            syncView: tableView
            boundsBehavior: Flickable.StopAtBounds
            resizableColumns: false
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            
            model: appDataViewController.selectedEntityTransformedModel
            
            delegate: Rectangle {
                implicitHeight: 30
                color: "transparent"
                
                Row {
                    spacing: 10
                    topPadding: 5
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Text {
                        leftPadding: 10
                        text: (modelData && modelData.display_name) ? modelData.display_name : ""
                        font.bold: true
                        font.pixelSize: 12
                        font.family: appTheme.rethinkSansFontName
                        color: "#888888"
                        verticalAlignment: Text.AlignVCenter
                    }

                    // >> Sort Indicator Container
                    Rectangle {
                        width: 14; height: 14
                        radius: 3
                        anchors.verticalCenter: parent.verticalCenter
                        color: appDataViewController.sortFieldIndex === index ? appTheme.activeColor : "transparent"
                        visible: appDataViewController.sortFieldIndex === index
                        
                        Text {
                            anchors.centerIn: parent
                            text: appDataViewController.sortAscending ? "▲" : "▼"
                            color: "black" 
                            font.pixelSize: 8
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appDataViewController.toggleSort(index)
                }
            }
        }

        // >> Bottom border for header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#D1D5DB"
        }

        // >> Table Body
        TableView {
            id: tableView
            model: appDataTableModel
            clip: true
            columnSpacing: 0
            rowSpacing: 0
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator { }
            ScrollIndicator.horizontal: ScrollIndicator { }

            Layout.fillWidth: true
            Layout.fillHeight: true

            property int hoveredRow: -1

            columnWidthProvider: function(column) {
                let entityName = appDataViewController.selectedEntityName;
                let contentWidth = appDataTableModel.getColumnWidth(column, entityName);
                
                if (column === tableView.columns - 1) {
                    let usedSpace = 0
                    for (let i = 0; i < tableView.columns - 1; i++) {
                        usedSpace += appDataTableModel.getColumnWidth(i, entityName)
                    }
                    let remainingSpace = tableView.width - usedSpace
                    return Math.max(contentWidth, remainingSpace)
                }
                return contentWidth
            }

            onWidthChanged: forceLayout()

            Connections {
                target: appDataTableModel
                function onModelReset() {
                    tableView.contentX = 0
                    tableView.contentY = 0
                    Qt.callLater(tableView.forceLayout)
                }
            }

            HoverHandler {
                onHoveredChanged: if (!hovered) tableView.hoveredRow = -1
            }

            delegate: Rectangle {
                implicitHeight: 30
                color: tableView.hoveredRow == row ? "#E5E7EB" : "white"
                
                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: if (hovered) tableView.hoveredRow = row
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // let rowData = appDataTableModel.getRowData(row)
                        // recordDialog.openForInfo(rowData)
                    }
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 10
                    verticalAlignment: Text.AlignVCenter
                    
                    text: {
                        if (model.display === undefined || model.display === null || model.display.length === 0)
                            return "None"
                        return model.display
                    }

                    font.family: appTheme.rethinkSansFontName
                    font.pixelSize: 12
                    color: (model.display) ? "#1F2937" : "#808080"
                    elide: Text.ElideRight
                }
            }
        }
    }
}