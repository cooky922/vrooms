import QtQuick
import QtQuick.Layouts
import "../../components" as Components

Item {
    id: loginScreen
    signal enterClicked()

    property int cardWidth: 250
    property int cardHeight: 300

    // > gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: appTheme.loginBgMainColor  }
            GradientStop { position: 0.3; color: appTheme.loginBgMainLastColor}
            GradientStop { position: 1.0; color: "white" }
        }
    }

    // > content
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Item {
            Layout.fillHeight: true
        }

        Column {
            spacing: 1
            Layout.alignment: Qt.AlignHCenter

            Components.AppLogo {
                id: mascot
                logoSize: 60
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Components.TitleText {
                text: "vrooms"
                textSize: 40
            }
        }

        LoginCardStack {
            Layout.alignment: Qt.AlignHCenter
            onEnterClicked: loginScreen.enterClicked()
        }
    }
}