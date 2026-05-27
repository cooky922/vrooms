import QtQuick

Text {
    property int textSize: 12
    property color textColor: appTheme.darkTextColor

    font.pixelSize: textSize
    font.family: appTheme.rethinkSansFontName
    color: textColor
}