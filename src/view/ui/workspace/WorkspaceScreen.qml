import QtQuick
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: workspaceScreen

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // > navigation pane [left]
            Item {
                Layout.preferredWidth: 150
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.bottomMargin: 5
                    spacing: 12

                    // >> app logo & title
                    RowLayout {
                        spacing: 8
                        
                        Components.AppLogo {
                            Layout.preferredWidth: 25
                            Layout.preferredHeight: 25
                        }

                        Components.TitleText {
                            text: "vrooms"
                            textSize: 24
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    // >> "new" button
                    Components.FloatingButton {
                        text: "New"
                        iconName: "add"
                        Layout.preferredWidth: implicitWidth 
                    }

                    // >> navigation group (TODO)
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            // > content pane [right]
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: 0
                    spacing: 12

                    // >> top bar
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Item {
                            Layout.fillWidth: true 
                        }

                        Components.PrimaryButton {
                            text: "User"
                            textSize: 13
                            iconName: "account"
                        }
                    }

                    // >> main content area
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        color: "#FFFFFF"
                        radius: 6
                        border {
                            color: appTheme.borderColor
                            width: 0.5
                        }
                    }

                    // >> bottom bar (TODO)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        
                        Components.InfoText {
                            text: "To Be Added"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        /*
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "VroomS!"
                font.pixelSize: 24
                font.family: appTheme.rokkittFontName
                color: "#333333"
            }

            Components.PrimaryButton {
                text: "Go to Login"
                iconName: "add"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

            Components.SecondaryButton {
                text: "Go to Login"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

            Components.FloatingButton {
                text: "Go to Login"
                Layout.alignment: Qt.AlignHCenter
                enableAnimate: true
                onClicked: stack.pop()
            }

        }
        */

    }
}