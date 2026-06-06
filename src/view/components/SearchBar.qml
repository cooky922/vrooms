import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root

    property string placeholderText: "Search..."
    property alias text: inputField.text
    property color parentBgColor: "#FFFFFF"
    
    property alias inputFocus: inputField.activeFocus

    signal accepted(string query)
    signal queryChanged(string query)
    signal cleared()

    implicitWidth: 320
    implicitHeight: 30

    readonly property string _iconSourceDirectory: "../../../assets/icons/"

    Item {
        id: container
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height

        readonly property bool isHovered: rootArea.containsMouse || clearMouseArea.containsMouse || inputField.hovered

        anchors.verticalCenterOffset: isHovered ? -2 : 0
        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        // > background rectangle with rounded corners
        Rectangle {
            anchors.fill: parent
            radius: height / 2 
            color: "#ECECEC"
        }

        // > content row
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 8
            spacing: 8

            // >> search icon
            Item {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14

                scale: root.text !== "" ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                Image {
                    id: searchIcon
                    source: root._iconSourceDirectory + "search.svg"
                    sourceSize.width: 16
                    sourceSize.height: 16
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: searchIcon
                    anchors.fill: searchIcon
                    colorizationColor: "#888888"
                    colorization: 1.0
                }
            }

            // >> text field
            TextField {
                id: inputField
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                placeholderText: root.placeholderText
                placeholderTextColor: "#888888" 
                
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 12
                color: "#333333"
                
                background: Item {} 
                
                leftPadding: 0
                rightPadding: 0
                verticalAlignment: TextInput.AlignVCenter

                onTextChanged: root.queryChanged(text)
                onAccepted: root.accepted(text)
            }

            // >> separator and clear button
            Item {
                id: clearSection
                Layout.preferredWidth: root.text !== "" ? 28 : 0
                Layout.fillHeight: true
                clip: true 
                opacity: root.text !== "" ? 1.0 : 0.0

                Behavior on Layout.preferredWidth { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    // >>> visual separator
                    Rectangle {
                        width: 2
                        height: root.height 
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.parentBgColor 
                    }

                    // >>> clear button
                    Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            
                            color: clearMouseArea.pressed ? "#CDCDCD" : (clearMouseArea.containsMouse ? "#DDDDDD" : "transparent")
                            scale: clearMouseArea.pressed ? 0.9 : 1.0
                            
                            Behavior on scale { NumberAnimation { duration: 100 } }
                        }

                        Image {
                            id: closeIcon
                            source: root._iconSourceDirectory + "close.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                            anchors.centerIn: parent
                            visible: false
                        }

                        MultiEffect {
                            source: closeIcon
                            anchors.fill: closeIcon
                            colorizationColor: "#888888"
                            colorization: 1.0
                        }

                        MouseArea {
                            id: clearMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                root.text = ""
                                root.cleared()
                                inputField.forceActiveFocus() 
                            }
                        }
                    }
                }
            }
        }
        
        MouseArea {
            id: rootArea
            anchors.fill: parent
            z: -1 
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            onClicked: inputField.forceActiveFocus()
        }
    }
}