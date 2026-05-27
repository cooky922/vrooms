import QtQuick

Text {
    property int textSize: 30
    property color textColor: "black"

    font.pixelSize: textSize
    font.bold: true
    font.family: appTheme.rokkittFontName
    color: textColor
}