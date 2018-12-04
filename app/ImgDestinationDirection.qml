import QtQuick 2.0

Item {
	id: img_destination_direction
    width: 100
    height: 100
    visible: false

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#a0a0a0"

        Image {
            id: direction
            anchors.fill: parent
            anchors.margins: 1
            source: "images/SW_Patern_3.bmp"
        }
    }

	states: [
        State {
            name: "0" // NoDirection
            PropertyChanges { target: img_destination_direction; visible: false }
//            PropertyChanges { target: direction; source: "images/SW_Patern_3.bmp" }
        },
        State {
            name: "1" // DirectionForward
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/5_straight.png" }
		},
		State {
            name: "2" // DirectionBearRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/11_2_bear_right_112px-Signal_C117a.svg.png" }
		},
		State {
            name: "3" // DirectionLightRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/4_slight_right.png" }
		},
		State {
            name: "4" // DirectionRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/3_right.png" }
		},
		State {
            name: "5" // DirectionHardRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/2_sharp_right.png" }
		},
		State {
            name: "6" // DirectionUTurnRight
            PropertyChanges { target: img_destination_direction; visible: true }
//            PropertyChanges { target: direction; source: "images/1_uturn.png" }
            PropertyChanges { target: direction; source: "images/7_left.png" } // No u-turn right in CES2019
        },
		State {
            name: "7" // DirectionUTurnLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/9_7_uturn_left.png" }
		},
		State {
            name: "8" // DirectionHardLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/8_sharp_left.png" }
		},
		State {
            name: "9" // DirectionLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/7_left.png" }
        },
        State {
            name: "10" // DirectionLightLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/6_slight_left.png" }
        },
        State {
            name: "11" // DirectionBearLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/10_11_bear_left_112px-Signal_C117a.svg.png" }
        },
        State {
            name: "12" // arrived at your destination
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/Dest_Flag.jpg" }
        },
        State {
            name: "invisible"
            PropertyChanges { target: img_destination_direction; visible: false }
        }

	]
}
