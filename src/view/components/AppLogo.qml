import QtQuick

Image {   
    source: "../../../../assets/icons/app-logo-plain.svg"

    property int logoSize: 60
    
    width: logoSize
    height: logoSize
    sourceSize.width: logoSize
    sourceSize.height: logoSize
    
    fillMode: Image.PreserveAspectFit
}