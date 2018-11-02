import QtGraphicalEffects 1.0
import QtLocation 5.9
import QtPositioning 5.0
import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0

import com.mapbox.cheap_ruler 1.0
import "qrc:/qml"

ApplicationWindow {
    id: window

    title: "QT MapboxGL Turn By Turn Navigation Demo"
    height: 768
    width: 1024
    visible: true

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        MapWindow {
            anchors.fill:  parent
        }
    }
}
