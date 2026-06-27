import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Popup {
    id: root

    property var rentData: ({})
    property string selectedUnitStatus: "Available"
    property string selectedSuggestion: ""

    anchors.centerIn: Overlay.overlay
    width: 420
    height: Math.min(implicitHeight, Overlay.overlay ? Overlay.overlay.height * 0.9 : 600)

    modal: true
    closePolicy: Popup.CloseOnEscape
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
        rentData           = {}
        selectedUnitStatus = "Available"
        selectedSuggestion = ""
    }

    // Has this rental gone past its expected return time?
    function isOverdue() {
        let expected = root.rentData["expectedReturnDateTime"]
        if (!expected) return false
        let expectedDate = new Date(String(expected).replace(" ", "T"))
        if (isNaN(expectedDate.getTime())) return false
        return Date.now() > expectedDate.getTime()
    }

    // Commits the rent + unit status change, then either opens Add Liability or just closes
    function finalizeReturn(addLiability) {
        let rentID = String(root.rentData["rentID"] || "")
        let result = appDataViewController.returnUnit(rentID, root.selectedUnitStatus)

        if (!result || !result.success) {
            console.log("[PostReturnDialog] Return failed:", result ? result.message : "unknown error")
            root.close()
            return
        }

        if (addLiability) {
            root.close()
            addDialog.entityName  = "liability"
            addDialog.prefillData = {
                "customerID":           result.customerID || "",
                "liabilityDescription": root.selectedSuggestion || "",
                "liabilityStatus":      "Pending"
            }
            addDialog.open()
        } else {
            root.close()
        }
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

            Text {
                text: "Return Unit"
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

        // ── Rent summary ─────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: summaryColumn.implicitHeight + 24
            radius: 10
            color: "#F3F4F6"
            border.color: "#D1D5DB"
            border.width: 0.5

            ColumnLayout {
                id: summaryColumn
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                spacing: 6

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; columnSpacing: 8; rowSpacing: 4

                    Text { text: "Rent ID";       font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#374151"; opacity: 0.7 }
                    Text { text: "#" + (root.rentData["rentID"] || "—"); font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#111827"; Layout.fillWidth: true; elide: Text.ElideRight }

                    Text { text: "Unit ID";       font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#374151"; opacity: 0.7 }
                    Text { text: root.rentData["unitID"]     || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#111827"; Layout.fillWidth: true; elide: Text.ElideRight }

                    Text { text: "Customer ID";   font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#374151"; opacity: 0.7 }
                    Text { text: root.rentData["customerID"] || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#111827"; Layout.fillWidth: true; elide: Text.ElideRight }

                    Text { text: "Expected Back"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; color: "#374151"; opacity: 0.7 }
                    Text { text: root.rentData["expectedReturnDateTime"] || "—"; font.family: appTheme.rethinkSansFontName; font.pixelSize: 11; font.bold: true; color: "#111827"; Layout.fillWidth: true; elide: Text.ElideRight }
                }

                Rectangle {
                    Layout.fillWidth: true
                    visible: root.isOverdue()
                    height: visible ? 22 : 0
                    radius: 6
                    color: "#FEE2E2"

                    Text {
                        anchors.centerIn: parent
                        text: "⚠ This rental is overdue"
                        font.family: appTheme.rethinkSansFontName
                        font.pixelSize: 11; font.bold: true
                        color: "#B91C1C"
                    }
                }
            }
        }

        // ── Unit condition (required) ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Unit Condition *"
                font.family: appTheme.rethinkSansFontName
                font.pixelSize: 13; font.bold: true
                color: "#1A1A1A"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 44; radius: 10
                    color: root.selectedUnitStatus === "Available" ? "#DCFCE7" : "#F3F4F6"
                    border.color: root.selectedUnitStatus === "Available" ? "#16A34A" : "#D1D5DB"
                    border.width: root.selectedUnitStatus === "Available" ? 1.5 : 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Available"
                        font.family: appTheme.rethinkSansFontName
                        font.pixelSize: 13; font.bold: true
                        color: root.selectedUnitStatus === "Available" ? "#15803D" : "#374151"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedUnitStatus = "Available"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 44; radius: 10
                    color: root.selectedUnitStatus === "Maintenance" ? "#FEF3C7" : "#F3F4F6"
                    border.color: root.selectedUnitStatus === "Maintenance" ? "#D97706" : "#D1D5DB"
                    border.width: root.selectedUnitStatus === "Maintenance" ? 1.5 : 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Maintenance"
                        font.family: appTheme.rethinkSansFontName
                        font.pixelSize: 13; font.bold: true
                        color: root.selectedUnitStatus === "Maintenance" ? "#92400E" : "#374151"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedUnitStatus = "Maintenance"
                    }
                }
            }
        }

        // ── Liability decision ──────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Add a liability for this customer?"
                font.family: appTheme.rethinkSansFontName
                font.pixelSize: 13; font.bold: true
                color: "#1A1A1A"
            }

            Text {
                text: "Optional — pick a reason below, or leave blank. Only one liability can be added per return."
                font.family: appTheme.rethinkSansFontName
                font.pixelSize: 11
                color: "#6B7280"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Flow {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: {
                        let suggestions = []
                        if (root.isOverdue())                          suggestions.push("Overdue Return")
                        if (root.selectedUnitStatus === "Maintenance") suggestions.push("Unit Under Maintenance")
                        suggestions.push("Unit Damage")
                        return suggestions
                    }
                    delegate: Rectangle {
                        width: chipLabel.implicitWidth + 20
                        height: 28; radius: 14
                        color: root.selectedSuggestion === modelData ? "#FDBA74" : "#FFF7ED"
                        border.color: "#FDBA74"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: chipLabel
                            anchors.centerIn: parent
                            text: modelData
                            font.family: appTheme.rethinkSansFontName
                            font.pixelSize: 11; font.bold: true
                            color: "#9A3412"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedSuggestion = (root.selectedSuggestion === modelData) ? "" : modelData
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.topMargin: 4

                Components.SecondaryButton {
                    text: "No"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    onClicked: root.finalizeReturn(false)
                }

                Components.PrimaryButton {
                    text: "Yes"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    buttonColor: "black"
                    textColor: "#FFFFFF"
                    onClicked: root.finalizeReturn(true)
                }
            }
        }
    }
}
