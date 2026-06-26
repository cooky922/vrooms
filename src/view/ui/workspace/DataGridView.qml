import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: root

    signal editRowRequested(int rowIndex)
    signal deleteRowRequested(int rowIndex)

    readonly property string entityName: appDataViewController.selectedEntityName
    
    property bool isImageMode: entityName.toLowerCase().indexOf("unit") >= 0 || entityName.toLowerCase().indexOf("customer") >= 0

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: 12
        clip: true

        cellWidth: Math.floor(width / Math.max(1, Math.min(5, Math.floor(width / 180))))
        
        cellHeight: {
            if (root.isImageMode) return cellWidth * 1.55;
            if (root.entityName.toLowerCase().indexOf("rent") >= 0) return 290;
            return 260;
        }

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
                color: "#F9FAFB" 
                
                border.color: "#E5E7EB"
                border.width: 1
                clip: true

                property var rowData: appDataTableModel.getRowData(index)
                property string eType: root.entityName.toLowerCase()

                // Card Hover Lift & Shadow
                HoverHandler { id: cardHover; cursorShape: Qt.PointingHandCursor }
                transform: Translate {
                    y: cardHover.hovered ? -3 : 0
                    Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: cardHover.hovered ? "#08000000" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    z: 0
                }

                // ==========================================
                // MORE ACTIONS BUTTON (⋮)
                // ==========================================
                Rectangle {
                    id: menuBtn
                    width: 32; height: 32; radius: 16
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10 
                    anchors.rightMargin: 8
                    
                    color: moreHover.hovered || moreTap.pressed ? "#1A000000" : "transparent" 
                    z: 10

                    Text {
                        anchors.centerIn: parent
                        text: "⋮"
                        font.pixelSize: 22 
                        color: "#4B5563"
                        font.bold: true
                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
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

                // ==========================================
                // LAYOUT 1: IMAGE MODE (Units, Customers)
                // ==========================================
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    z: 1
                    visible: root.isImageMode

                    // > Image / Icon Area
                    Rectangle {
                        id: imageFrame
                        Layout.fillWidth: true
                        Layout.preferredHeight: (card.height - 24) * 0.62 
                        color: "#E5E7EB" 
                        radius: 8
                        clip: true

                        property bool hasPicture: {
                            if (!card.rowData) return false;
                            if (card.eType.indexOf("unit") >= 0 && card.rowData["unitPicture"]) return true;
                            if (card.eType.indexOf("customer") >= 0 && card.rowData["profilePicture"]) return true;
                            return false;
                        }

                        Image {
                            id: cardImage
                            anchors.centerIn: parent
                            
                            width: parent.hasPicture ? parent.width : 48
                            height: parent.hasPicture ? parent.height : 48
                            sourceSize: parent.hasPicture ? Qt.size(imageFrame.width, imageFrame.height) : Qt.size(48, 48)
                            fillMode: parent.hasPicture ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                            
                            source: {
                                if (parent.hasPicture) {
                                    let picPath = card.eType.indexOf("unit") >= 0 ? card.rowData["unitPicture"] : card.rowData["profilePicture"]
                                    return "file:///" + picPath.replace(/\\/g, "/")
                                }
                                return card.eType.indexOf("unit") >= 0 ? "../../../../assets/icons/unit.svg" : "../../../../assets/icons/customer.svg"
                            }
                            opacity: parent.hasPicture ? 1.0 : 0.4
                        }
                    }

                    // > Info Area
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 2

                        // 1. Name Title
                        Text {
                            Layout.fillWidth: true
                            text: {
                                if (!card.rowData) return "";
                                if (card.eType.indexOf("unit") >= 0)
                                    return ((card.rowData["unitBrand"] || "") + " " + (card.rowData["unitModel"] || "")).trim() || "Unknown Model"
                                return ((card.rowData["firstName"] || "") + " " + (card.rowData["lastName"] || "")).trim() || "Unknown Name"
                            }
                            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#111827"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }

                        // 2. Direct Identifier
                        Text {
                            Layout.fillWidth: true
                            text: {
                                if (!card.rowData) return "";
                                return card.eType.indexOf("unit") >= 0 ? "Unit #" + (card.rowData["unitID"] || "—") : "Customer #" + (card.rowData["customerID"] || "—")
                            }
                            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                            font.pixelSize: 11
                            color: "#6B7280"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }

                        // 3. License / Plate Number
                        Text {
                            Layout.fillWidth: true
                            text: {
                                if (!card.rowData) return "";
                                return card.eType.indexOf("unit") >= 0 ? (card.rowData["plateNumber"] || "—") : (card.rowData["driverLicenseID"] || "—")
                            }
                            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                            font.pixelSize: 11
                            color: "#6B7280"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillHeight: true }

                        // 4. Bottom Row (Price & Status)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: {
                                    if (!card.rowData) return "";
                                    return card.eType.indexOf("unit") >= 0 ? "₱" + (card.rowData["dailyRate"] || "0") + "/day" : ""
                                }
                                font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#111827"
                                visible: text !== ""
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                height: 20
                                width: statusTextImg.implicitWidth + 16
                                radius: 10
                                color: root.getStatusConfig(card.rowData, card.eType).bg
                                Text {
                                    id: statusTextImg
                                    anchors.centerIn: parent
                                    text: root.getStatusConfig(card.rowData, card.eType).text
                                    font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: root.getStatusConfig(card.rowData, card.eType).fg
                                }
                            }
                        }
                    }
                }

                // ==========================================
                // LAYOUT 2: TEXT MODE (Rents, Payments, Liab)
                // ==========================================
                Item {
                    anchors.fill: parent
                    z: 1
                    visible: !root.isImageMode

                    // 1. Title Row
                    Item {
                        id: titleRow
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 52 

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 44 
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (!card.rowData) return "";
                                if (card.eType.indexOf("rent") >= 0) return "Rent #" + (card.rowData["rentID"] || "—")
                                if (card.eType.indexOf("payment") >= 0) return "Payment #" + (card.rowData["paymentID"] || "—")
                                return card.rowData["liabilityDescription"] || ("Liability #" + (card.rowData["liabilityID"] || "—"))
                            }
                            font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#111827"
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    // 2. Line Separator
                    Rectangle { 
                        id: separatorLine
                        anchors.top: titleRow.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: "#E5E7EB" 
                    }

                    // 3. Info Area (Chips & Status)
                    ColumnLayout {
                        anchors.top: separatorLine.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        spacing: 6

                        // Dynamic Chips
                        Repeater {
                            model: root.getCardDetails(card.rowData, card.eType)
                            delegate: Rectangle {
                                Layout.alignment: Qt.AlignLeft
                                width: chipCol.implicitWidth + 20
                                height: chipCol.implicitHeight + 10
                                radius: 8
                                color: "#F3F4F6"
                                
                                ColumnLayout {
                                    id: chipCol
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    anchors.topMargin: 5
                                    anchors.bottomMargin: 5
                                    spacing: 2
                                    
                                    Text { 
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignLeft
                                        text: modelData.label
                                        font.pixelSize: modelData.text === "" ? 12 : 11
                                        font.bold: modelData.text === ""
                                        color: modelData.text === "" ? "#374151" : "#4B5563"
                                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif" 
                                    }
                                    
                                    Text { 
                                        visible: modelData.text !== ""
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignLeft
                                        text: modelData.text
                                        font.pixelSize: 10
                                        color: "#6B7280"
                                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif" 
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true } 

                        // 4. Bottom Row (Special Status Chips)
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Item { Layout.fillWidth: true } 

                            Rectangle {
                                height: 22
                                width: paymentChipContent.implicitWidth + 20
                                radius: 11
                                color: root.getStatusConfig(card.rowData, card.eType).bg
                                Layout.alignment: Qt.AlignBottom
                                
                                RowLayout {
                                    id: paymentChipContent
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Image {
                                        source: root.getStatusConfig(card.rowData, card.eType).icon
                                        sourceSize: Qt.size(12, 12)
                                        visible: source.toString() !== "" 
                                        opacity: 0.8
                                    }

                                    Text {
                                        text: root.getStatusConfig(card.rowData, card.eType).text
                                        font.family: typeof appTheme !== "undefined" ? appTheme.rethinkSansFontName : "sans-serif"
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: root.getStatusConfig(card.rowData, card.eType).fg
                                    }
                                }
                            }
                        }
                    }
                }

                // --- Tap Navigation ---
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

    // ==========================================
    // HELPER FUNCTIONS
    // ==========================================
    function getCardDetails(row, eType) {
        if (!row) return [];
        let details = [];

        let formatDT = (dt) => {
            return typeof appUtils !== "undefined" ? appUtils.formatDateTime(dt) : dt;
        };

        if (eType.indexOf("rent") >= 0) {
            details.push({ label: "Unit #" + (row["unitID"] || "—"), text: "" });
            details.push({ label: "Customer #" + (row["customerID"] || "—"), text: "" });
            
            if (row["rentDateTime"]) 
                details.push({ label: "Rent Time", text: formatDT(row["rentDateTime"]) });
                
            if (row["rentStatus"] === "Closed" && row["actualReturnDateTime"]) 
                details.push({ label: "Return Time", text: formatDT(row["actualReturnDateTime"]) });
                
        } 
        else if (eType.indexOf("payment") >= 0) {
            details.push({ label: "Customer #" + (row["customerID"] || "—"), text: "" });
            details.push({ label: "Paid Amount", text: "₱" + Number(row["paidAmount"] || 0).toLocaleString(Qt.locale(), 'f', 2) });
            
            if (row["paymentDateTime"]) 
                details.push({ label: "Payment Time", text: formatDT(row["paymentDateTime"]) });
                
        } 
        else if (eType.indexOf("liability") >= 0) {
            details.push({ label: "Customer #" + (row["customerID"] || "—"), text: "" });
            details.push({ label: "Fee", text: "₱" + Number(row["liabilityFee"] || 0).toLocaleString(Qt.locale(), 'f', 2) });
            
            if (row["issuedDateTime"]) 
                details.push({ label: "Issued Time", text: formatDT(row["issuedDateTime"]) });
        }
        
        return details;
    }

    function getStatusConfig(row, eType) {
        if (!row) return { text: "", bg: "transparent", fg: "transparent", icon: "" };

        if (eType.indexOf("payment") >= 0) {
            if (row["liabilityID"]) {
                return { text: "Liability", bg: "#FFEDD5", fg: "#9A3412", icon: "" }; 
            } else {
                return { text: "Rent", bg: "#EFF6FF", fg: "#1E3A8A", icon: "" }; 
            }
        }
        
        let s = row["unitStatus"] || row["customerStatus"] || row["rentStatus"] || row["liabilityStatus"] || "—";
        if (s === "Available" || s === "Active" || s === "Paid" || s === "Completed" || s === "Settled") 
            return { text: s, bg: "#D1FAE5", fg: "#065F46", icon: "" };
        if (s === "Rented" || s === "Inactive" || s === "Overdue" || s === "Unpaid" || s === "Blacklisted") 
            return { text: s, bg: "#FEE2E2", fg: "#991B1B", icon: "" };
        if (s === "Pending" || s === "Ongoing" || s === "Maintenance") 
            return { text: s, bg: "#FEF3C7", fg: "#92400E", icon: "" };
            
        return { text: s, bg: "#E5E7EB", fg: "#374151", icon: "" };
    }
}