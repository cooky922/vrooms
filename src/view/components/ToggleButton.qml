import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: control
    checkable: true 

    signal toggled(bool isChecked)
    onCheckedChanged: control.toggled(control.checked)

    property string iconName: ""
    property string checkIconName: "check" 
    readonly property string _iconSourceDirectory: "../../../assets/icons/"

    readonly property bool isFirst: control.parent && control.parent.children[0] === control
    readonly property bool isLast: control.parent && control.parent.children[control.parent.children.length - 1] === control

    Text {
        id: hiddenText
        text: control.text
        font.family: appTheme.inclusiveSansFontName
        font.pixelSize: 13
        font.weight: Font.Bold
        visible: false
    }

    property int _iconW: control.iconName !== "" ? 18 : 0
    property int _textW: control.text !== "" ? hiddenText.implicitWidth : 0
    property int _spacing: (control.iconName !== "" && control.text !== "") ? 6 : 0
    property int _contentW: _iconW + _textW + _spacing + 22
    
    implicitWidth: Math.max(32, _contentW + 12)
    implicitHeight: parent ? parent.height : 26

    // > background divider
    background: Item {
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height
            color: "#888888" 
            visible: !isLast
        }
    }

    contentItem: Item {
        anchors.fill: parent
        
        Row {
            id: contentRow
            anchors.centerIn: parent
            
            anchors.verticalCenterOffset: (control.hovered && !control.checked) ? -2 : 0
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            spacing: 6

            // > active checkmark (if checkable)
            Item {
                width: control.checked ? 16 : 0
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                clip: true 
                
                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                Image {
                    id: checkIcon
                    source: control._iconSourceDirectory + control.checkIconName + ".svg"
                    sourceSize.width: 14
                    sourceSize.height: 14
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: false
                }

                MultiEffect {
                    source: checkIcon
                    anchors.fill: checkIcon
                    colorizationColor: "#001D35" 
                    colorization: 1.0
                }
            }

            // > main icon (if any)
            Item {
                width: control.iconName !== "" ? 18 : 0
                height: control.iconName !== "" ? 18 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: control.iconName !== ""
                
                opacity: control.checked ? 1.0 : 0.35
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Image {
                    id: mainIcon
                    source: control.iconName !== "" ? control._iconSourceDirectory + control.iconName + ".svg" : ""
                    sourceSize.width: 14
                    sourceSize.height: 14
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: mainIcon
                    anchors.fill: mainIcon
                    colorizationColor: control.checked ? "#001D35" : "#888888"
                    colorization: 1.0
                    Behavior on colorizationColor { ColorAnimation { duration: 150 } }
                }
            }

            // > text label (if any)
            Text {
                text: control.text
                visible: control.text !== ""
                font.family: appTheme.inclusiveSansFontName
                font.pixelSize: 13
                font.weight: control.checked ? Font.Bold : Font.Medium
                color: control.checked ? "#000000" : "#333333"
                
                opacity: control.checked ? 1.0 : 0.35
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton 
    }
}