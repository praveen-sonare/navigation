import QtQuick 2.0
import QtQuick.Controls 2.2

import "qrc:/qml"

ApplicationWindow {
    id: window

    title: "Turn By Turn Navigation Demo"
    height: 720
    width: 640
    visible: true

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        MapWindow {
            id:mapwindow
            anchors.fill:  parent
            objectName: "mapwindow"
        }
    }
}
