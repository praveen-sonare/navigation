import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0

Item {
    id: dateAndTime

    width: 53 * hspan
    height: 33 * vspan

    property int hspan: 4
    property int vspan: 1
    property var currentDate: new Date();

    RowLayout {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        CustomLabel {
            font.capitalization: Font.AllUppercase
            text: Qt.formatDateTime(dateAndTime.currentDate, "HH:mm")
            font.pixelSize: 38
            color: "#000000"
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            dateAndTime.currentDate = new Date();
        }
    }
}
