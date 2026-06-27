import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components
import "form" as FormElements

Popup {
    id: root

    property string entityName: ""
    property var currentSchema: appEntitySchemaMap[root.entityName] || []
    property var viewData: ({})

    // rent data for this unit (populated when unitStatus === "Rented")
    property var activeRentData: ({})

    // customer sub-records (populated when entityName === "customer")
    property var customerPayments:    []
    property var customerLiabilities: []
    property var customerActiveRent:  null
    property var customerPastRents:   []

    anchors.centerIn: Overlay.overlay
    width: 480
    height: Overlay.overlay ? Overlay.overlay.height * 0.95 : 800

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: Popup.Center

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale";   from: 0.85; to: 1.0;  duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            NumberAnimation { property: "opacity"; from: 0.0;  to: 1.0;  duration: 250 }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale";   from: 1.0;  to: 0.85; duration: 200; easing.type: Easing.InBack }
            NumberAnimation { property: "opacity"; from: 1.0;  to: 0.0;  duration: 200 }
        }
    }

    onClosed: {
        viewData            = {}
        entityName          = ""
        activeRentData      = {}
        customerPayments    = []
        customerLiabilities = []
        customerActiveRent  = null
        customerPastRents   = []
    }

    onOpened: {
        let e = root.entityName.toLowerCase()

        // unit — fetch active rent when Rented
        if (e.indexOf("unit") >= 0 && root.viewData["unitStatus"] === "Rented") {
            let rentData        = appDataViewController.getActiveRentForUnit(root.viewData["unitID"] || "")
            root.activeRentData = rentData || {}
        }

        // customer — fetch linked payments, liabilities & rents
        if (e.indexOf("customer") >= 0) {
            let cid                  = root.viewData["customerID"] || ""
            root.customerPayments    = appDataViewController.getPaymentsForCustomer(cid)
            root.customerLiabilities = appDataViewController.getLiabilitiesForCustomer(cid)

            let rents = appDataViewController.getRentsForCustomer(cid) || []
            root.customerActiveRent = rents.find(function(r) { return r["rentStatus"] === "Ongoing" }) || null
            root.customerPastRents  = rents.filter(function(r) { return r["rentStatus"] !== "Ongoing" })
        }
    }

    // Navigate to a related Customer or Unit record
    function openRelatedRecord(fieldKey) {
        let targetEntity = ""
        if (fieldKey === "customerID") {
            targetEntity = "customer"
        } else if (fieldKey === "unitID") {
            targetEntity = "unit"
        } else if (fieldKey === "liabilityID") {
            targetEntity = "liability"
        }
        let targetId     = String(root.viewData[fieldKey] || "")
        root.close()
        Qt.callLater(function() {
            workspaceScreen.navigateToRecord(targetEntity, targetId)
        })
    }

    Overlay.modal: Rectangle {
        color: "#40000000"
    }

    background: Rectangle {
        color: "#FAFAFA"
        radius: 16
    }

    contentItem: ColumnLayout {
        spacing: 16

        // ── Header ────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                source: {
                    let entityName = appDataViewController.selectedEntityName
                    return `../../../../assets/icons/${entityName}.svg`
                }
                sourceSize: Qt.size(24, 24)
                Layout.alignment: Qt.AlignVCenter
                opacity: 0.8
            }

            Text {
                text: "View " + appUtils.capitalize(root.entityName)
                font { pixelSize: 20; bold: true; family: appTheme.inclusiveSansFontName }
                color: "#1A1A1A"
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: closeMouseArea.containsMouse ? "#EEEEEE" : "transparent"

                Image {
                    source: "../../../../assets/icons/close.svg"
                    sourceSize: Qt.size(14, 14)
                    anchors.centerIn: parent
                    opacity: 0.7
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    preventStealing: true
                    onClicked: (mouse) => {
                        mouse.accepted = true
                        root.close()
                    }
                }
            }
        }

        // ── Scrollable body ───────────────────────────────────────────────────
        ScrollView {
            id: formScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ColumnLayout {
                width: formScroll.availableWidth
                spacing: 16

                // ── Field repeater ────────────────────────────────────────────
                Repeater {
                    model: root.currentSchema
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        z: root.currentSchema.length - index
                        spacing: 2

                        Loader {
                            id: fieldLoader
                            Layout.fillWidth: true
                            asynchronous: true
                            opacity: status === Loader.Ready ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            source: {
                                switch (modelData.type) {
                                    case "text":     return "form/FormText.qml"
                                    case "real":     return "form/FormReal.qml"
                                    case "int":      return "form/FormInt.qml"
                                    case "date":     return "form/FormDate.qml"
                                    case "datetime": return "form/FormDateTime.qml"
                                    case "select":   return "form/FormSelect.qml"
                                    case "file":     return "form/FormFile.qml"
                                    default:         return "form/FormText.qml"
                                }
                            }

                            onLoaded: {
                                item.fieldKey   = modelData.key
                                item.label      = modelData.label
                                item.isRequired = false
                                item.isViewOnly = true
                                if (modelData.options) item.options = modelData.options
                            }

                            Binding {
                                when: fieldLoader.status === Loader.Ready
                                target: fieldLoader.item
                                property: "value"
                                value: root.viewData[modelData.key] !== undefined ? root.viewData[modelData.key] : ""
                                restoreMode: Binding.RestoreBinding
                            }
                        }

                        // "View Customer →" / "View Unit →" link
                        RowLayout {
                            Layout.fillWidth: true
                            visible: {
                                return root.viewData[modelData.key] !== undefined
                                    && (root.entityName === "rent" ||
                                        root.entityName === "liability" ||
                                        root.entityName === "payment") &&
                                        modelData.is_foreign_key
                            }
                            spacing: 0

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: fkLinkLabel.implicitWidth + 16
                                height: 15; radius: 6
                                color: fkLinkArea.containsMouse ? "#E0E7FF" : "#EEF2FF"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: fkLinkLabel
                                    anchors.centerIn: parent
                                    text: {
                                        let name = ""
                                        if (modelData.key === "customerID") {
                                            name = "Customer"
                                        } else if (modelData.key === "unitID") {
                                            name = "Unit"
                                        } else if (modelData.key === "liabilityID") {
                                            name = "Liability"
                                        }
                                        return "View " + name + " →"
                                    }
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 10; font.bold: true
                                    color: "#4338CA"
                                }

                                MouseArea {
                                    id: fkLinkArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: root.openRelatedRecord(modelData.key)
                                }
                            }
                        }
                    }
                }

                // ── Active rent info (units only, when Rented) ────────────────
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.entityName.toLowerCase().indexOf("unit") >= 0
                             && root.viewData["unitStatus"] === "Rented"
                    implicitHeight: rentInfoColumn.implicitHeight + 24
                    height: visible ? implicitHeight : 0
                    radius: 10
                    color: "#FEF3C7"
                    border.color: "#FCD34D"
                    border.width: 0.5

                    ColumnLayout {
                        id: rentInfoColumn
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle { width: 8; height: 8; radius: 4; color: "#D97706" }

                            Text {
                                text: "Currently Rented"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 12; font.bold: true
                                color: "#92400E"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Rent #" + (root.activeRentData["rentID"] || "—")
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 11
                                color: "#92400E"
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2; columnSpacing: 8; rowSpacing: 4

                            Text { text: "Customer ID";  font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#78350F"; opacity: 0.7 }
                            Text { text: root.activeRentData["customerID"]     || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#78350F"; Layout.fillWidth: true; elide: Text.ElideRight }

                            Text { text: "Rent Date";    font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#78350F"; opacity: 0.7 }
                            Text { text: root.activeRentData["rentDateTime"]   || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#78350F"; Layout.fillWidth: true; elide: Text.ElideRight }

                            Text { text: "Return Date";  font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#78350F"; opacity: 0.7 }
                            Text { text: root.activeRentData["expectedReturnDateTime"] || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#78350F"; Layout.fillWidth: true; elide: Text.ElideRight }

                            Text { text: "Status";       font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#78350F"; opacity: 0.7 }
                            Text { text: root.activeRentData["rentStatus"]     || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#78350F"; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                    }
                }

                // ── Rentals section (customer only) ───────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.entityName.toLowerCase().indexOf("customer") >= 0
                    implicitHeight: rentalsColumn.implicitHeight + 24
                    height: visible ? implicitHeight : 0
                    radius: 10
                    color: "#EFF6FF"
                    border.color: "#93C5FD"
                    border.width: 0.5

                    ColumnLayout {
                        id: rentalsColumn
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle { width: 8; height: 8; radius: 4; color: "#2563EB" }

                            Text {
                                text: "Rentals"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 12; font.bold: true
                                color: "#1E3A8A"
                            }

                            Text {
                                text: "(" + (root.customerPastRents.length + (root.customerActiveRent ? 1 : 0)) + ")"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 11
                                color: "#1E3A8A"; opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: createRentLabel.implicitWidth + 16
                                height: 24; radius: 6
                                color: createRentArea.containsMouse ? "#DBEAFE" : "#BFDBFE"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: createRentLabel
                                    anchors.centerIn: parent
                                    text: "+ Create Rent"
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 11; font.bold: true
                                    color: "#1D4ED8"
                                }

                                MouseArea {
                                    id: createRentArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.close()
                                        appDataViewController.reselectEntity("rent")
                                        addDialog.entityName  = "rent"
                                        addDialog.prefillData = { "customerID": root.viewData["customerID"] || "" }
                                        addDialog.open()
                                    }
                                }
                            }
                        }

                        // Currently renting callout
                        Rectangle {
                            Layout.fillWidth: true
                            visible: root.customerActiveRent !== null
                            implicitHeight: activeRentColumn.implicitHeight + 16
                            height: visible ? implicitHeight : 0
                            radius: 8
                            color: "#DBEAFE"
                            border.color: "#60A5FA"
                            border.width: 0.5

                            ColumnLayout {
                                id: activeRentColumn
                                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Currently Renting"
                                        font.family: appTheme.rethinkSansFontName
                                        font.pixelSize: 11; font.bold: true
                                        color: "#1E40AF"
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "Rent #" + (root.customerActiveRent ? (root.customerActiveRent["rentID"] || "—") : "—")
                                        font.family: appTheme.rethinkSansFontName
                                        font.pixelSize: 10
                                        color: "#1E40AF"; opacity: 0.8
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2; columnSpacing: 8; rowSpacing: 2

                                    Text { text: "Unit ID";   font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; color: "#1E40AF"; opacity: 0.7 }
                                    Text { text: root.customerActiveRent ? (root.customerActiveRent["unitID"] || "—") : "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E40AF"; Layout.fillWidth: true; elide: Text.ElideRight }

                                    Text { text: "Rent Date"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; color: "#1E40AF"; opacity: 0.7 }
                                    Text { text: root.customerActiveRent ? (root.customerActiveRent["rentDateTime"] || "—") : "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E40AF"; Layout.fillWidth: true; elide: Text.ElideRight }

                                    Text { text: "Due Back";  font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; color: "#1E40AF"; opacity: 0.7 }
                                    Text { text: root.customerActiveRent ? (root.customerActiveRent["expectedReturnDateTime"] || "—") : "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E40AF"; Layout.fillWidth: true; elide: Text.ElideRight }
                                }
                            }
                        }

                        Text {
                            visible: root.customerActiveRent === null && root.customerPastRents.length === 0
                            text: "No rentals recorded."
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11
                            color: "#1E3A8A"; opacity: 0.55
                            Layout.fillWidth: true
                        }

                        // Past rentals table
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.customerPastRents.length > 0
                            spacing: 0

                            Text {
                                text: "Past Rentals"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 10; font.bold: true
                                color: "#1E3A8A"; opacity: 0.6
                                Layout.topMargin: root.customerActiveRent !== null ? 4 : 0
                                Layout.bottomMargin: 4
                            }

                            // Header row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text { text: "ID";        font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E3A8A"; opacity: 0.5; Layout.preferredWidth: 40 }
                                Text { text: "Unit ID";   font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E3A8A"; opacity: 0.5; Layout.preferredWidth: 60 }
                                Text { text: "Rent Date"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E3A8A"; opacity: 0.5; Layout.fillWidth: true }
                                Text { text: "Status";    font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#1E3A8A"; opacity: 0.5; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                            }

                            Repeater {
                                model: root.customerPastRents
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text { text: "#" + (modelData["rentID"] || "—");       font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#1E3A8A"; Layout.preferredWidth: 40;  elide: Text.ElideRight }
                                    Text { text: modelData["unitID"] || "—";               font.family: appTheme.rethinkSansFontName; font.pixelSize: 11;                color: "#1E3A8A"; Layout.preferredWidth: 60;  elide: Text.ElideRight }
                                    Text { text: modelData["rentDateTime"] || "—";         font.family: appTheme.rethinkSansFontName; font.pixelSize: 11;                color: "#1E3A8A"; Layout.fillWidth: true;     elide: Text.ElideRight }
                                    Text { text: modelData["rentStatus"] || "—";           font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#1E3A8A"; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                }

                // ── Payments section (customer only) ──────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.entityName.toLowerCase().indexOf("customer") >= 0
                    implicitHeight: paymentsColumn.implicitHeight + 24
                    height: visible ? implicitHeight : 0
                    radius: 10
                    color: "#F0FDF4"
                    border.color: "#86EFAC"
                    border.width: 0.5

                    ColumnLayout {
                        id: paymentsColumn
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle { width: 8; height: 8; radius: 4; color: "#16A34A" }

                            Text {
                                text: "Payments"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 12; font.bold: true
                                color: "#14532D"
                            }

                            Text {
                                text: "(" + root.customerPayments.length + ")"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 11
                                color: "#14532D"; opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: addPaymentLabel.implicitWidth + 16
                                height: 24; radius: 6
                                color: addPaymentArea.containsMouse ? "#DCFCE7" : "#BBF7D0"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: addPaymentLabel
                                    anchors.centerIn: parent
                                    text: "+ Add Payment"
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 11; font.bold: true
                                    color: "#15803D"
                                }

                                MouseArea {
                                    id: addPaymentArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.close()
                                        appDataViewController.reselectEntity("payment")
                                        addDialog.entityName  = "payment"
                                        addDialog.prefillData = { "customerID": root.viewData["customerID"] || "" }
                                        addDialog.open()
                                    }
                                }
                            }
                        }

                        Text {
                            visible: root.customerPayments.length === 0
                            text: "No payments recorded."
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11
                            color: "#166534"; opacity: 0.55
                            Layout.fillWidth: true
                        }

                        ColumnLayout {
                            visible: root.customerPayments.length > 0
                            Layout.fillWidth: true
                            spacing: 2

                            // Header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text { text: "ID";          font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#14532D"; opacity: 0.5; Layout.preferredWidth: 40 }
                                Text { text: "Date / Time"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#14532D"; opacity: 0.5; Layout.fillWidth: true }
                                Text { text: "Amount";      font.family: appTheme.rethinkSansFontName; font.pixelSize: 10; font.bold: true; color: "#14532D"; opacity: 0.5; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                            }

                            Repeater {
                                model: root.customerPayments
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    height: 28; radius: 6
                                    color: index % 2 === 0 ? "#DCFCE7" : "#F0FDF4"

                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                        spacing: 0
                                        Text { text: "#" + (modelData["paymentID"] || "—");                                           font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#14532D"; Layout.preferredWidth: 40;                              elide: Text.ElideRight }
                                        Text { text: modelData["paymentDateTime"] || "—";                                              font.family: appTheme.rethinkSansFontName; font.pixelSize: 11;                color: "#14532D"; Layout.fillWidth: true;                               elide: Text.ElideRight }
                                        Text { text: modelData["paidAmount"] !== undefined ? "₱" + Number(modelData["paidAmount"]).toLocaleString(Qt.locale(), 'f', 2) : "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#14532D"; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Liabilities section (customer only) ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.entityName.toLowerCase().indexOf("customer") >= 0
                    implicitHeight: liabilitiesColumn.implicitHeight + 24
                    height: visible ? implicitHeight : 0
                    radius: 10
                    color: "#FFF7ED"
                    border.color: "#FDBA74"
                    border.width: 0.5

                    ColumnLayout {
                        id: liabilitiesColumn
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle { width: 8; height: 8; radius: 4; color: "#EA580C" }

                            Text {
                                text: "Liabilities"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 12; font.bold: true
                                color: "#7C2D12"
                            }

                            Text {
                                text: "(" + root.customerLiabilities.length + ")"
                                font.family: appTheme.rethinkSansFontName
                                font.pixelSize: 11
                                color: "#7C2D12"; opacity: 0.6
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: addLiabilityLabel.implicitWidth + 16
                                height: 24; radius: 6
                                color: addLiabilityArea.containsMouse ? "#FED7AA" : "#FDBA74"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    id: addLiabilityLabel
                                    anchors.centerIn: parent
                                    text: "+ Add Liability"
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 11; font.bold: true
                                    color: "#9A3412"
                                }

                                MouseArea {
                                    id: addLiabilityArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.close()
                                        appDataViewController.reselectEntity("liability")
                                        addDialog.entityName  = "liability"
                                        addDialog.prefillData = { "customerID": root.viewData["customerID"] || "" }
                                        addDialog.open()
                                    }
                                }
                            }
                        }

                        Text {
                            visible: root.customerLiabilities.length === 0
                            text: "No liabilities recorded."
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11
                            color: "#7C2D12"; opacity: 0.55
                            Layout.fillWidth: true
                        }

                        GridLayout {
                            visible: root.customerLiabilities.length > 0
                            Layout.fillWidth: true
                            columns: 4; columnSpacing: 8

                            Repeater {
                                model: ["ID", "Issued", "Fee (₱)", "Status"]
                                delegate: Text {
                                    text: modelData
                                    font.family: appTheme.rethinkSansFontName
                                    font.pixelSize: 10; font.bold: true
                                    color: "#7C2D12"; opacity: 0.5
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Repeater {
                            model: root.customerLiabilities
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: liabilityGrid.implicitHeight + 10
                                radius: 6
                                color: index % 2 === 0 ? "#FED7AA" : "#FFF7ED"

                                GridLayout {
                                    id: liabilityGrid
                                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                                    columns: 4; columnSpacing: 8

                                    Text { text: "#" + (modelData["liabilityID"] || "—");                                                                                    font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#7C2D12"; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: modelData["issuedDateTime"] || "—";                                                                                         font.family: appTheme.rethinkSansFontName; font.pixelSize: 11;                color: "#7C2D12"; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: modelData["liabilityFee"] !== undefined ? "₱" + Number(modelData["liabilityFee"]).toLocaleString(Qt.locale(), 'f', 2) : "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#7C2D12"; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: modelData["liabilityStatus"] || "—";                                                                                        font.family: appTheme.rethinkSansFontName; font.pixelSize: 11;                color: "#7C2D12"; Layout.fillWidth: true; elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Footer buttons ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Components.PrimaryButton {
                text: "Create Rent"
                Layout.preferredHeight: 32
                iconName: "rent"
                visible: root.entityName.toLowerCase().indexOf("unit") >= 0
                         && root.viewData["unitStatus"] === "Available"
                onClicked: {
                    root.close()
                    appDataViewController.reselectEntity("rent")
                    addDialog.entityName  = "rent"
                    addDialog.prefillData = { "unitID": root.viewData["unitID"] || "" }
                    addDialog.open()
                }
            }

            Components.PrimaryButton {
                text: "Return Unit"
                Layout.preferredHeight: 32
                visible: root.entityName.toLowerCase() === "rent"
                         && root.viewData["rentStatus"] === "Ongoing"
                onClicked: {
                    postReturnDialog.rentData = root.viewData
                    root.close()
                    Qt.callLater(function() { postReturnDialog.open() })
                }
            }

            Components.SecondaryButton {
                text: "Add Payment"
                Layout.preferredHeight: 32
                visible: root.entityName.toLowerCase() === "rent"
                onClicked: {
                    root.close()
                    appDataViewController.reselectEntity("payment")
                    addDialog.entityName  = "payment"
                    addDialog.prefillData = { "customerID": root.viewData["customerID"] || "" }
                    addDialog.open()
                }
            }

            Components.PrimaryButton {
                text: "Pay"
                Layout.preferredHeight: 32
                visible: root.entityName.toLowerCase() === "liability"
                         && root.viewData["liabilityStatus"] === "Pending"
                onClicked: {
                    root.close()
                    appDataViewController.reselectEntity("payment")
                    addDialog.entityName  = "payment"
                    addDialog.prefillData = {
                        "customerID":  root.viewData["customerID"]  || "",
                        "liabilityID": root.viewData["liabilityID"] || ""
                    }
                    addDialog.open()
                }
            }

            Item { Layout.fillWidth: true }

            Components.PrimaryButton {
                text: "Close"
                Layout.preferredHeight: 32
                onClicked: root.close()
            }
        }
    }
}
