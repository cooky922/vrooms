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
            GradientStop { id: stop1; position: 0.0; color: appTheme.loginBgMainColor  }
            GradientStop { id: stop2; position: 0.3; color: appTheme.loginBgMainLastColor}
            GradientStop { id: stop3; position: 1.0; color: "white" }
        }

        // > add subtle animation to the gradient
        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation { target: stop1; property: "position"; to: 0.35; duration: 3500; easing.type: Easing.InOutSine }
                NumberAnimation { target: stop2; property: "position"; to: 0.85; duration: 3500; easing.type: Easing.InOutSine }
            }

            ParallelAnimation {
                NumberAnimation { target: stop1; property: "position"; to: -0.25; duration: 3500; easing.type: Easing.InOutSine }
                NumberAnimation { target: stop2; property: "position"; to: 0.10; duration: 3500; easing.type: Easing.InOutSine }
            }
            
            ParallelAnimation {
                NumberAnimation { target: stop1; property: "position"; to: 0.0; duration: 3500; easing.type: Easing.InOutSine }
                NumberAnimation { target: stop2; property: "position"; to: 0.3; duration: 3500; easing.type: Easing.InOutSine }
            }
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