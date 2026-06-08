import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    // Set these before opening to pre-fill the form
    property string unitPlate: ""
    property string unitModel: ""
    property string unitRegDate: ""
    property string unitRate: ""
    property string unitPhoto: ""

    signal saveClicked(var unitData)

    anchors.centerIn: Overlay.overlay
    width: 420
    modal: true
    closePolicy: Popup.CloseOnEscape

    // Pre-fill fields whenever the popup opens----------------------------
    onOpened: {
        plateField.text    = root.unitPlate
        modelField.text    = root.unitModel
        regDateField.text  = root.unitRegDate
        rateField.text     = root.unitRate
        photoUpload.photoPath = root.unitPhoto
    }

    onClosed: {
        plateField.text       = ""
        modelField.text       = ""
        regDateField.text     = Qt.formatDate(new Date(), "MMM dd, yyyy")
        rateField.text        = ""
        photoUpload.photoPath = ""
    }

    Overlay.modal: Rectangle { color: "#40000000" }

    background: Rectangle {
        color: "#FAFAFA"
        radius: 16
    }

    contentItem: ColumnLayout {
        spacing: 16

        // edit unit header ----------------------------------------
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Edit Unit"
                font { pixelSize: 20; bold: true; family: appTheme.rethinkSansFontName }
                color: "#1A1A1A"
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: closeHover.hovered ? "#E5E7EB" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 16; color: "#555" }
                HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.close() }
            }
        }

        // > plate number------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Plate number <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            TextField {
                id: plateField
                Layout.fillWidth: true
                placeholderText: "e.g. ABC 1234"
                leftPadding: 16; rightPadding: 16
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
                placeholderTextColor: "#AAAAAA"
                background: Rectangle {
                    radius: 24; color: "white"
                    border { color: plateField.activeFocus ? appTheme.activeColor : "transparent"; width: 1.5 }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }
        }

        // > model----------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Model <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            TextField {
                id: modelField
                Layout.fillWidth: true
                placeholderText: "e.g. Honda"
                leftPadding: 16; rightPadding: 16
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
                placeholderTextColor: "#AAAAAA"
                background: Rectangle {
                    radius: 24; color: "white"
                    border { color: modelField.activeFocus ? appTheme.activeColor : "transparent"; width: 1.5 }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }
        }

        // > registration date-----------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Registration date <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            TextField {
                id: regDateField
                Layout.fillWidth: true
                placeholderText: "e.g. Jan 12, 2024"
                leftPadding: 16; rightPadding: 16
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
                placeholderTextColor: "#AAAAAA"
                background: Rectangle {
                    radius: 24; color: "white"
                    border { color: regDateField.activeFocus ? appTheme.activeColor : "transparent"; width: 1.5 }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }

            // >> date shortcut buttons----------------------------------
            RowLayout {
                spacing: 8

                Repeater {
                    model: [
                        { label: "Use today's date", action: "today" },
                        { label: "Clear",            action: "clear" }
                    ]

                    Rectangle {
                        required property var modelData
                        implicitHeight: 34
                        implicitWidth: btnRow.implicitWidth + 24
                        radius: 24
                        border { color: "#C0C7D0"; width: 1 }
                        color: btnHover.hovered ? "#E5E7EB" : "white"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            id: btnRow
                            anchors.centerIn: parent
                            spacing: 6

                            Image {
                                source: "../../../../assets/icons/calendar.svg"
                                sourceSize: Qt.size(14, 14)
                                opacity: 0.6
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: modelData.label
                                font { pixelSize: 12; family: appTheme.rethinkSansFontName }
                                color: "#444"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler { id: btnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: regDateField.text = modelData.action === "today"
                                ? Qt.formatDate(new Date(), "MMM dd, yyyy")
                                : ""
                        }
                    }
                }
            }

            Text {
                text: "Type a date or use the buttons above"
                font { pixelSize: 10; family: appTheme.rethinkSansFontName }
                color: "#AAAAAA"
            }
        }

        // > daily rate------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Daily rate (₱) <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            TextField {
                id: rateField
                Layout.fillWidth: true
                placeholderText: "e.g. 300"
                leftPadding: 16; rightPadding: 16
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
                placeholderTextColor: "#AAAAAA"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: RegularExpressionValidator { regularExpression: /^\d*\.?\d*$/ }
                background: Rectangle {
                    radius: 24; color: "white"
                    border { color: rateField.activeFocus ? appTheme.activeColor : "transparent"; width: 1.5 }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }
        }

        // > status (active, rented, maintenance) ------------------------------
        ColumnLayout { 
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Status <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            ComboBox {
                id: statusField
                Layout.fillWidth: true
                model: ["Available", "Rented", "Under Maintenance"]
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }

                background: Rectangle {
                    radius: 24; color: "white"
                    border { color: statusField.activeFocus ? appTheme.activeColor : "#C0C7D0"; width: 1.5 }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    leftPadding: 16
                    text: statusField.displayText
                    font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                    color: "#333"
                    verticalAlignment: Text.AlignVCenter
                }

                popup: Popup {
                    y: statusField.height + 4
                    width: statusField.width
                    padding: 6

                    background: Rectangle {
                        color: "#FAFAFA"
                        radius: 10
                        border.color: "#E0E0E0"
                        border.width: 1
                    }

                    contentItem: ListView {
                        implicitHeight: contentHeight
                        model: statusField.popup.visible ? statusField.delegateModel : null
                        clip: true
                    }
                }

                delegate: ItemDelegate {
                    width: statusField.width - 12
                    height: 36

                    background: Rectangle {
                        radius: 8
                        color: hovered ? "#F0F0F0" : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }
                    }

                    contentItem: Text {
                        leftPadding: 12
                        text: modelData
                        font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                        color: "#333"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // > photo upload
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Photo of the Unit <font color='#E53935'>*</font>"
                textFormat: Text.RichText
                font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                color: "#333"
            }

            Rectangle {
                id: photoUpload
                property string photoPath: ""

                Layout.fillWidth: true
                height: 90; radius: 12
                color: dropArea.containsDrag ? "#EBF3FB" : "white"
                border { color: dropArea.containsDrag ? appTheme.activeColor : "#C0C7D0"; width: 1.5 }
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "../../../../assets/icons/upload.svg"
                        sourceSize: Qt.size(28, 28)
                        opacity: 0.55
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: photoUpload.photoPath !== "" ? photoUpload.photoPath : "Browse Files"
                        font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                        color: "#444"
                        elide: Text.ElideMiddle
                        width: Math.min(implicitWidth, photoUpload.width - 32)
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Drag and Drop Files"
                        font { pixelSize: 11; family: appTheme.rethinkSansFontName }
                        color: "#888"
                        visible: photoUpload.photoPath === ""
                    }
                }

                // >> clear photo button
                Rectangle {
                    visible: photoUpload.photoPath !== ""
                    anchors { top: parent.top; right: parent.right; margins: 6 }
                    width: 20; height: 20; radius: 10
                    color: clearPhotoHover.hovered ? "#E5E7EB" : "#F3F4F6"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: "#555" }

                    HoverHandler { id: clearPhotoHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: photoUpload.photoPath = "" }
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    onDropped: (drop) => { if (drop.hasUrls) photoUpload.photoPath = drop.urls[0] }
                }

                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }

        }

        // > action buttons-------------------------

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }


            // CANCEL BUTTON--------------------------------------
            Rectangle {
                implicitWidth: 90; implicitHeight: 36; radius: 10
                color: cancelHover.hovered ? "#C8CDD4" : "#D4D9DF"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font { pixelSize: 13; family: appTheme.rethinkSansFontName }
                    color: "#333"
                }
                HoverHandler { id: cancelHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.close() }
            }


            //SAVE CHANGES BUTTON---------------------------------------
            Rectangle {
                implicitWidth: 110; implicitHeight: 36; radius: 10
                color: saveHover.hovered ? Qt.darker(appTheme.activeColor, 1.08) : appTheme.activeColor
                Behavior on color { ColorAnimation { duration: 100 } }

                // Disable if required fields are empty
                opacity: (plateField.text !== "" && modelField.text !== "" && rateField.text !== "") ? 1.0 : 0.5

                Text {
                    anchors.centerIn: parent
                    text: "Save Changes"
                    font { pixelSize: 13; bold: true; family: appTheme.rethinkSansFontName }
                    color: "black"
                }


                HoverHandler { id: saveHover; cursorShape: Qt.PointingHandCursor }
            
                    TapHandler {
                    onTapped: {
                        if (plateField.text === "" || modelField.text === "" || rateField.text === "")
                            return
                        root.saveClicked({
                            plate:   plateField.text,
                            model:   modelField.text,
                            regDate: regDateField.text,
                            rate:    rateField.text,
                            photo:   photoUpload.photoPath
                        })
                        root.close()
                    }
                }
            }
        }
    }
}
