import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../../components" as Components

Popup {
    id: root

    signal addClicked(var unitData)

    anchors.centerIn: Overlay.overlay
    width: 420
    height: Math.min(implicitHeight, Overlay.overlay ? Overlay.overlay.height * 0.9 : 600)
    
    modal: true
    closePolicy: Popup.CloseOnEscape
    transformOrigin: Popup.Center

    // Entry and Exit Animations
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250 }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 200; easing.type: Easing.InBack }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        }
    }

    onClosed: {
        plateField.text = ""
        modelField.text = ""
        regDateField.text = Qt.formatDate(new Date(), "MMM dd, yyyy")
        rateField.text = ""
        photoUpload.photoPath = ""
        statusChip.selectedValue = "" 
    }

    Overlay.modal: Rectangle { color: "#40000000" }

    background: Rectangle {
        color: "#FAFAFA"
        radius: 16
    }

    contentItem: ColumnLayout {
        id: contentLayout
        spacing: 16

        // > title bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                source: "../../../../assets/icons/unit.svg"
                sourceSize: Qt.size(24, 24)
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "New Unit"
                font { pixelSize: 20; bold: true; family: appTheme.inclusiveSansFontName }
                color: "#1A1A1A"
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: closeHover.hovered ? "#E5E7EB" : "transparent"

                Image {
                    source: "../../../../assets/icons/close.svg"
                    sourceSize: Qt.size(14, 14)
                    anchors.centerIn: parent
                    opacity: 0.7
                }

                HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.close() }
            }
        }

        // > Scrollable Form Area
        ScrollView {
            id: formScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true 
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            contentWidth: availableWidth 

            ColumnLayout {
                width: formScrollView.availableWidth
                spacing: 16

                // > plate number
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Plate number <font color='#E53935'>*</font>"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    TextField {
                        id: plateField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        placeholderText: "e.g. ABC 1234"
                        leftPadding: 12; rightPadding: 32
                        font { pixelSize: 12; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                        placeholderTextColor: "#AAAAAA"
                        
                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: plateField.activeFocus ? appTheme.activeColor : "#888888"
                            border.width: plateField.activeFocus ? 2 : 0.75
                        }

                        HoverHandler { id: plateHover }
                        transform: Translate {
                            y: plateHover.hovered ? -2 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

                        Rectangle {
                            visible: plateField.text !== ""
                            width: 20; height: 20; radius: 10
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            color: plateClearHover.hovered ? "#E5E7EB" : "transparent"
                            Image {
                                anchors.centerIn: parent
                                source: "../../../../assets/icons/close.svg"
                                sourceSize: Qt.size(12, 12)
                                opacity: 1.0
                            }
                            HoverHandler { id: plateClearHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: plateField.text = "" }
                        }
                    }
                }

                // > model
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Model <font color='#E53935'>*</font>"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    TextField {
                        id: modelField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        placeholderText: "e.g. Honda"
                        leftPadding: 12; rightPadding: 32
                        font { pixelSize: 12; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                        placeholderTextColor: "#AAAAAA"
                        
                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: modelField.activeFocus ? appTheme.activeColor : "#888888"
                            border.width: modelField.activeFocus ? 2 : 0.75
                        }

                        HoverHandler { id: modelHover }
                        transform: Translate {
                            y: modelHover.hovered ? -2 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

                        Rectangle {
                            visible: modelField.text !== ""
                            width: 20; height: 20; radius: 10
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            color: modelClearHover.hovered ? "#E5E7EB" : "transparent"
                            Image {
                                anchors.centerIn: parent
                                source: "../../../../assets/icons/close.svg"
                                sourceSize: Qt.size(12, 12)
                                opacity: 1.0
                            }
                            HoverHandler { id: modelClearHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: modelField.text = "" }
                        }
                    }
                }

                // > registration date
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Registration date <font color='#E53935'>*</font>"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    TextField {
                        id: regDateField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        text: Qt.formatDate(new Date(), "MMM dd, yyyy")
                        placeholderText: "e.g. Jan 12, 2024"
                        leftPadding: 12
                        rightPadding: regDateField.text === "" ? todayBtn.width + 12 : 32
                        
                        font { pixelSize: 12; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                        placeholderTextColor: "#AAAAAA"
                        
                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: regDateField.activeFocus ? appTheme.activeColor : "#888888"
                            border.width: regDateField.activeFocus ? 2 : 0.75
                        }

                        HoverHandler { id: regHover }
                        transform: Translate {
                            y: regHover.hovered ? -2 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

                        Rectangle {
                            id: todayBtn
                            visible: regDateField.text === ""
                            anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                            height: 24; width: todayRow.implicitWidth + 16; radius: 12
                            color: todayHover.hovered ? "#E5E7EB" : "transparent"
                            
                            Row {
                                id: todayRow
                                anchors.centerIn: parent
                                spacing: 4
                                Image {
                                    source: "../../../../assets/icons/calendar.svg"
                                    sourceSize: Qt.size(12, 12)
                                    opacity: 1.0
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Use today's date"
                                    font { pixelSize: 11; family: appTheme.inclusiveSansFontName }
                                    color: "#555"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            HoverHandler { id: todayHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: regDateField.text = Qt.formatDate(new Date(), "MMM dd, yyyy") }
                        }

                        Rectangle {
                            visible: regDateField.text !== ""
                            width: 20; height: 20; radius: 10
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            color: regClearHover.hovered ? "#E5E7EB" : "transparent"
                            Image {
                                anchors.centerIn: parent
                                source: "../../../../assets/icons/close.svg"
                                sourceSize: Qt.size(12, 12)
                                opacity: 1.0
                            }
                            HoverHandler { id: regClearHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: regDateField.text = "" }
                        }
                    }
                }

                // > daily rate
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Daily rate (₱) <font color='#E53935'>*</font>"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    TextField {
                        id: rateField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        placeholderText: "e.g. 300"
                        leftPadding: 12; rightPadding: 32
                        font { pixelSize: 12; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                        placeholderTextColor: "#AAAAAA"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: RegularExpressionValidator { regularExpression: /^\d*\.?\d*$/ }
                        
                        background: Rectangle {
                            radius: 15
                            color: "transparent"
                            border.color: rateField.activeFocus ? appTheme.activeColor : "#888888"
                            border.width: rateField.activeFocus ? 2 : 0.75
                        }

                        HoverHandler { id: rateHover }
                        transform: Translate {
                            y: rateHover.hovered ? -2 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

                        Rectangle {
                            visible: rateField.text !== ""
                            width: 20; height: 20; radius: 10
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            color: rateClearHover.hovered ? "#E5E7EB" : "transparent"
                            Image {
                                anchors.centerIn: parent
                                source: "../../../../assets/icons/close.svg"
                                sourceSize: Qt.size(12, 12)
                                opacity: 1.0
                            }
                            HoverHandler { id: rateClearHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: rateField.text = "" }
                        }
                    }
                }

                // > status
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    z: 5 

                    Text {
                        text: "Status <font color='#E53935'>*</font>"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    Components.DropdownChip {
                        id: statusChip
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        menuWidth: statusChip.width 
                        isSmall: true
                        label: "Select Status"
                        selectedValue: "" 
                        model: ["Available", "Rented", "Under Maintenance"]
                    }
                }

                // > photo upload
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Photo of the Unit"
                        textFormat: Text.RichText
                        font { pixelSize: 13; family: appTheme.inclusiveSansFontName }
                        color: "#333"
                    }

                    FileDialog {
                        id: imageDialog
                        title: "Select an Image"
                        nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
                        onAccepted: {
                            photoUpload.photoPath = selectedFile
                        }
                    }

                    Rectangle {
                        id: photoUpload
                        property string photoPath: ""

                        Layout.fillWidth: true
                        height: 90; radius: 12
                        color: {
                            if (photoUpload.photoPath !== "")
                                return "#C2E7FF"
                            else if (dropArea.containsDrag)
                                return "#EBF3FB"
                            else
                                return "transparent"
                        }
                        border { 
                            color: dropArea.containsDrag ? appTheme.activeColor : "#888888"
                            width: photoUpload.photoPath !== "" ? 0 : 0.75 
                        }

                        HoverHandler { id: photoHover; cursorShape: Qt.PointingHandCursor }
                        
                        transform: Translate {
                            y: photoHover.hovered ? -2 : 0
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        }

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
                        }

                        Rectangle {
                            visible: photoUpload.photoPath !== ""
                            anchors { top: parent.top; right: parent.right; margins: 6 }
                            width: 20; height: 20; radius: 10
                            color: clearPhotoHover.hovered ? "#1A001D35" : "transparent"
                            Image {
                                anchors.centerIn: parent
                                source: "../../../../assets/icons/close.svg"
                                sourceSize: Qt.size(12, 12)
                                opacity: 1.0
                            }
                            HoverHandler { id: clearPhotoHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: photoUpload.photoPath = "" }
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onDropped: (drop) => { if (drop.hasUrls) photoUpload.photoPath = drop.urls[0] }
                        }
                        TapHandler { onTapped: imageDialog.open() }
                    }
                }
            }
        }

        // > action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Item { Layout.fillWidth: true }
            Components.SecondaryButton {
                text: "Cancel"
                enableAnimate: true
                Layout.preferredHeight: 32
                onClicked: root.close()
            }
            Components.PrimaryButton {
                text: "Add"
                enableAnimate: true
                Layout.preferredHeight: 32
                enabled: plateField.text !== "" && modelField.text !== "" && rateField.text !== "" && statusChip.selectedValue !== ""
                opacity: enabled ? 1.0 : 0.5
                onClicked: {
                    if (!enabled) return
                    root.addClicked({
                        plateNumber: plateField.text,
                        unitModel: modelField.text,
                        registrationDate: regDateField.text,
                        dailyRate: rateField.text,
                        unitStatus: statusChip.selectedValue,
                        unitPicture: photoUpload.photoPath
                    })
                    root.close()
                }
            }
        }
    }
}