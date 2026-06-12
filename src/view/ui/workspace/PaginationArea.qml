import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 30

    // > displays the number of records
    Components.InfoText {
        text: {
            let total_item_count = appDataViewController.totalItemCount
            if (total_item_count <= appDataViewController.pageSize) {
                if (total_item_count === 0) 
                    return "Showing zero items"
                else if (total_item_count === 1)
                    return "Showing one item"
                else
                    return `Showing all ${total_item_count} items`
            }
            let from = appDataViewController.pageIndex * appDataViewController.pageSize + 1
            let to = appDataViewController.pageIndex * appDataViewController.pageSize + appDataViewController.visibleItemCount
            return `Showing ${from}-${to} of ${total_item_count} items`
        }
        textSize: 11
        textColor: "#888888"
        Layout.alignment: Qt.AlignVCenter
    }

    Item { Layout.fillWidth: true }

    // main page control
    Row {
        spacing: 5
        visible: appDataViewController.totalPages !== 1
        Layout.alignment: Qt.AlignVCenter

        // > displays the page status
        Row {
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter

            Components.InfoText {
                text: "Page "
                textSize: 11
                textColor: "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: pageInput
                width: Math.max(25, contentWidth + 20)
                height: 20
                
                leftPadding: 5
                rightPadding: 5
                topPadding: 0
                bottomPadding: 0
                anchors.verticalCenter: parent.verticalCenter
                // > restricts input strictly to numbers between 1 and totalPages
                validator: RegularExpressionValidator { 
                    regularExpression: /^[1-9][0-9]*$/ 
                }
                text: (appDataViewController.pageIndex + 1).toString()
                maximumLength: appDataViewController.totalPages.toString().length
                
                font.pixelSize: 11
                font.family: appTheme.rethinkSansFontName
                color: "#444444"
                horizontalAlignment: TextInput.AlignHCenter

                property bool isInputValid: {
                    let num = parseInt(text)
                    return !isNaN(num) && num >= 1 && num <= appDataViewController.totalPages
                }

                background: Rectangle {
                    radius: 4
                    color: "white"
                    border.width: 1
                    border.color: {
                        if (!pageInput.isInputValid)
                            return "#E53935"
                        else if (pageInput.activeFocus)
                            return appTheme.activeColor || "#888888"
                        else
                            return "#CCCCCC"
                    }
                }

                onEditingFinished: {
                    if (isInputValid) {
                        appDataViewController.setPage(parseInt(text))
                        focus = false
                    } else {
                        text = (appDataViewController.pageIndex + 1).toString()
                        focus = false
                    }
                }

                Connections {
                    target: appDataViewController
                    function onPaginationChanged() {
                        if (!pageInput.activeFocus) {
                            pageInput.text = (appDataViewController.pageIndex + 1).toString()
                        }
                    }
                }
            }

            Components.InfoText {
                text: " / "
                textSize: 13
                textColor: "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }

            Components.InfoText {
                text: appDataViewController.totalPages
                textSize: 11
                textColor: "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Item { width: 5; height: 1 }

        // > separator
        Rectangle {
            width: 1.5
            height: 15
            radius: 1
            color: "#bbbbbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: 5; height: 1 }

        // > first page button
        Components.PrimaryButton {
            text: "◀◀"
            textSize: 14
            width: 28
            height: 24
            enabled: appDataViewController.pageIndex > 0
            opacity: enabled ? 1.0 : 0.5
            onClicked: appDataViewController.setFirstPage()
            anchors.verticalCenter: parent.verticalCenter
        }

        // > prev button
        Components.PrimaryButton {
            text: "◀"
            textSize: 14
            width: 28
            height: 24
            enabled: appDataViewController.pageIndex > 0
            opacity: enabled ? 1.0 : 0.5
            onClicked: appDataViewController.prevPage()
            anchors.verticalCenter: parent.verticalCenter
        }

        // > next button
        Components.PrimaryButton {
            text: "▶"
            textSize: 14
            width: 28
            height: 24
            enabled: appDataViewController.pageIndex < (appDataViewController.totalPages - 1)
            opacity: enabled ? 1.0 : 0.5
            onClicked: appDataViewController.nextPage()
            anchors.verticalCenter: parent.verticalCenter
        }

        // > last page button
        Components.PrimaryButton {
            text: "▶▶"
            textSize: 14
            width: 28
            height: 24
            enabled: appDataViewController.pageIndex < (appDataViewController.totalPages - 1)
            opacity: enabled ? 1.0 : 0.5
            onClicked: appDataViewController.setLastPage()
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}