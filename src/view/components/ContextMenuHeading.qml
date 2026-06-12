import QtQuick

Item {
    id: root
    width: parent ? parent.width : 200
    height: 28
    
    property string text: ""
    
    Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font { pixelSize: 11; bold: true; family: appTheme.rethinkSansFontName }
        color: "#5F6368" // Standard un-focused gray
    }
}