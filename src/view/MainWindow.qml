import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "ui/login" as LoginUI
import "ui/workspace" as WorkspaceUI

ApplicationWindow {
    id: app
    width: 800
    minimumWidth: 800
    height: 500
    minimumHeight: 500

    visible: true
    title: "VroomS - Motor Rental Management System"

    StackView {
        id: stack
        anchors.fill: parent

        pushEnter:  Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 240; easing.type: Easing.OutQuad } }
        pushExit:   Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 160; easing.type: Easing.InQuad } }
        popEnter:   Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 240; easing.type: Easing.OutQuad } }
        popExit:    Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 160; easing.type: Easing.InQuad } }

        initialItem: loginComponent
    }

    Component {
        id: loginComponent
        LoginUI.LoginScreen {
            onEnterClicked: stack.push(workspaceComponent)
        }
    }

    Component {
        id: workspaceComponent
        WorkspaceUI.WorkspaceScreen {}
    }
}