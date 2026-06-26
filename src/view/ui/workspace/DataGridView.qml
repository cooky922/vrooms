import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: root

    signal editRowRequested(int rowIndex)
    signal deleteRowRequested(int rowIndex)

    readonly property string entityName: appDataViewController.selectedEntityName

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: 12
        clip: true

        cellWidth: Math.floor(width / Math.max(1, Math.min(5, Math.floor(width / 180))))
        cellHeight: cellWidth * 1.3

        model: appDataTableModel
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Rectangle {
                id: card
                anchors.fill: parent
                anchors.margins: 6
                radius: 12
                color: "#E8E8E8"
                border.color: appTheme.borderColor
                border.width: 0.5
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: cardHover.hovered ? "#08000000" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    z: 0
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    z: 1

                    // > image / icon area (polaroid-style inset)
                    Rectangle {
                        id: imageFrame
                        Layout.fillWidth: true
                        Layout.preferredHeight: (card.height - 20) * 0.68
                        color: "#FFFFFF"
                        radius: 6
                        clip: true

                        Image {
                            id: cardImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop

                            source: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                let picPath = ""

                                if (e.indexOf("unit") >= 0)
                                    picPath = row["unitPicture"] || ""
                                else if (e.indexOf("customer") >= 0)
                                    picPath = row["profilePicture"] || ""

                                if (picPath !== "")
                                    return "file:///" + picPath.replace(/\\/g, "/")

                                // fallback icon
                                if (e.indexOf("unit") >= 0) return "../../../../assets/icons/unit.svg"
                                if (e.indexOf("customer") >= 0) return "../../../../assets/icons/customer.svg"
                                if (e.indexOf("rent") >= 0) return "../../../../assets/icons/rent.svg"
                                if (e.indexOf("payment") >= 0) return "../../../../assets/icons/payment.svg"
                                return "../../../../assets/icons/liability.svg"
                            }

                            sourceSize: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                let hasPic = (e.indexOf("unit") >= 0 && row["unitPicture"]) ||
                                             (e.indexOf("customer") >= 0 && row["profilePicture"])
                                return hasPic ? Qt.size(imageFrame.width, imageFrame.height) : Qt.size(40, 40)
                            }

                            anchors.centerIn: hasPicture ? undefined : parent

                            property bool hasPicture: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                return (e.indexOf("unit") >= 0 && row["unitPicture"] && row["unitPicture"] !== "") ||
                                       (e.indexOf("customer") >= 0 && row["profilePicture"] && row["profilePicture"] !== "")
                            }

                            opacity: hasPicture ? 1.0 : 0.2
                        }

                        Rectangle {
                            id: menuBtn
                            width: 28; height: 28; radius: 14
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            color: moreHover.hovered || moreTap.pressed ? "#E5E7EB" : "#FFFFFF"
                            opacity: 0.92
                            scale: moreTap.pressed ? 0.92 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                            z: 10

                            Text {
                                anchors.centerIn: parent
                                text: "⋮"
                                font.pixelSize: 16
                                color: "#555555"
                                font.bold: true
                            }

                            HoverHandler { id: moreHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { id: moreTap; onTapped: rowMenu.toggle() }

                            Components.ContextMenu {
                                id: rowMenu
                                x: parent.width - rowMenu.width + 6
                                smartPositioning: true

                                Components.ContextMenuItem {
                                    text: "Edit"; iconName: "edit"
                                    onTriggered: { rowMenu.close(); root.editRowRequested(index) }
                                }
                                Components.ContextMenuItem {
                                    text: "Delete"; iconName: "delete"; itemColor: "#EF4444"
                                    onTriggered: { rowMenu.close(); root.deleteRowRequested(index) }
                                }
                            }
                        }
                    }

                    // > info area
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 3

                        // > title
                        Text {
                            Layout.fillWidth: true
                            text: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                if (e.indexOf("unit") >= 0)
                                    return (row["unitBrand"] || "") + " " + (row["unitModel"] || "") || "Unknown Model"
                                if (e.indexOf("customer") >= 0)
                                    return ((row["firstName"] || "") + " " + (row["lastName"] || "")).trim() || "Unknown"
                                if (e.indexOf("rent") >= 0)
                                    return "Rental #" + (row["rentID"] || index + 1)
                                if (e.indexOf("payment") >= 0)
                                    return "Payment #" + (row["paymentID"] || index + 1)
                                return row["liabilityDescription"] || "Liability"
                            }
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 12
                            font.bold: true
                            color: "#111827"
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        // > subtitle
                        Text {
                            Layout.fillWidth: true
                            text: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                if (e.indexOf("unit") >= 0)
                                    return row["plateNumber"] || ""
                                if (e.indexOf("customer") >= 0)
                                    return row["driverLicenseID"] || ""
                                if (e.indexOf("rent") >= 0)
                                    return "Unit ID: " + (row["unitID"] || "—")
                                if (e.indexOf("payment") >= 0)
                                    return "Customer #" + (row["customerID"] || "—")
                                return "Fee: ₱" + (row["liabilityFee"] || "0")
                            }
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11
                            color: "#6B7280"
                            elide: Text.ElideRight
                        }

                        // > extra line for Rent/Payment
                        Text {
                            Layout.fillWidth: true
                            text: {
                                let row = appDataTableModel.getRowData(index)
                                let e = root.entityName.toLowerCase()
                                if (e.indexOf("rent") >= 0)
                                    return "Customer ID: " + (row["customerID"] || "—")
                                if (e.indexOf("payment") >= 0)
                                    return "₱" + (row["paidAmount"] || "0")
                                return ""
                            }
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11
                            color: "#6B7280"
                            elide: Text.ElideRight
                            visible: {
                                let e = root.entityName.toLowerCase()
                                return e.indexOf("rent") >= 0 || e.indexOf("payment") >= 0
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // > bottom row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: {
                                    let row = appDataTableModel.getRowData(index)
                                    let e = root.entityName.toLowerCase()
                                    if (e.indexOf("unit") >= 0)
                                        return "₱" + (row["dailyRate"] || "0") + "/day"
                                    if (e.indexOf("rent") >= 0)
                                        return row["rentDateTime"] || ""
                                    if (e.indexOf("payment") >= 0)
                                        return row["paymentDateTime"] || ""
                                    return ""
                                }
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 11
                                color: "#374151"
                                elide: Text.ElideRight
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                height: 18
                                width: statusText.implicitWidth + 12
                                radius: 9
                                color: {
                                    let row = appDataTableModel.getRowData(index)
                                    let s = row["unitStatus"] || row["customerStatus"] || row["rentStatus"] || row["liabilityStatus"] || ""
                                    if (s === "Available" || s === "Active" || s === "Paid" || s === "Completed") return "#D1FAE5"
                                    if (s === "Rented" || s === "Inactive" || s === "Overdue" || s === "Unpaid") return "#FEE2E2"
                                    if (s === "Pending" || s === "Ongoing") return "#FEF3C7"
                                    return "#F3F4F6"
                                }

                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: {
                                        let row = appDataTableModel.getRowData(index)
                                        return row["unitStatus"] || row["customerStatus"] || row["rentStatus"] || row["liabilityStatus"] || "—"
                                    }
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 10
                                    color: {
                                        let row = appDataTableModel.getRowData(index)
                                        let s = row["unitStatus"] || row["customerStatus"] || row["rentStatus"] || row["liabilityStatus"] || ""
                                        if (s === "Available" || s === "Active" || s === "Paid" || s === "Completed") return "#065F46"
                                        if (s === "Rented" || s === "Inactive" || s === "Overdue" || s === "Unpaid") return "#991B1B"
                                        if (s === "Pending" || s === "Ongoing") return "#92400E"
                                        return "#6B7280"
                                    }
                                }
                            }
                        }
                    }
                }

                HoverHandler { id: cardHover; cursorShape: Qt.PointingHandCursor }

                TapHandler {
                    enabled: !moreHover.hovered && !rowMenu.opened
                    onTapped: {
                        viewDialog.entityName = appDataViewController.selectedEntityName
                        viewDialog.viewData = appDataTableModel.getRowData(index)
                        viewDialog.open()
                    }
                }
            }
        }
    }
}