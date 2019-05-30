import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
    id: btn_present_position

    Button {
        id: btn_present_position_
		width: 100
		height: 100
        visible: false

        function present_position_clicked() {
            map.center = map.currentpostion
            btn_present_position.state = "Flowing"
        }
        onClicked: { present_position_clicked() }

        Image {
            id: image_present_position
            width: 48
            height: 92
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/207px-Car_icon_top.svg.png"
        }
    }
    states: [
        State{
            name: "Flowing"
            PropertyChanges { target: btn_present_position_; visible: false }
        },
        State{
            name: "Optional"
            PropertyChanges { target: btn_present_position_; visible: true }
        }
    ]

}
