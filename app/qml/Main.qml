import QtGraphicalEffects 1.0
import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import QtWebSockets 1.0

import "qrc:/qml"

ApplicationWindow {
    id: window

    title: "QT MapboxGL Turn By Turn Navigation Demo"
    height: 720
    width: 640
    visible: true

    function startDemo(visible) {
        console.log("startDemo")
        mapwindow.do_autostart()
    }

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        MapWindow {
            id:mapwindow
            anchors.fill:  parent
        }
    }
}
