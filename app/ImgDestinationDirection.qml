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
        },
        State {
            name: "1" // DirectionForward
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_N.png" }
		},
		State {
            name: "2" // DirectionBearRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/11_2_bear_right_112px-Signal_C117a.svg.png" }
		},
		State {
            name: "3" // DirectionLightRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_NE.png" }
		},
		State {
            name: "4" // DirectionRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_E.png" }
		},
		State {
            name: "5" // DirectionHardRight
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_SE.png" }
		},
		State {
            name: "6" // DirectionUTurnRight
            PropertyChanges { target: img_destination_direction; visible: true }
//            PropertyChanges { target: direction; source: "images/146px-Israely_road_sign_211.svg.png" }
            PropertyChanges { target: direction; source: "images/146px-Israely_road_sign_212.svg.png" } // No u-turn right in CES2019
        },
		State {
            name: "7" // DirectionUTurnLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/146px-Israely_road_sign_212.svg.png" }
		},
		State {
            name: "8" // DirectionHardLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_SW.png" }
		},
		State {
            name: "9" // DirectionLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_W.png" }
        },
        State {
            name: "10" // DirectionLightLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/145px-16_cardinal_points_NW.png" }
        },
        State {
            name: "11" // DirectionBearLeft
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/10_11_bear_left_112px-Signal_C117a.svg.png" }
        },
        State {
            name: "12" // arrived at your destination
            PropertyChanges { target: img_destination_direction; visible: true }
            PropertyChanges { target: direction; source: "images/Emoji_u1f3c1.svg" }
        },
        State {
            name: "invisible"
            PropertyChanges { target: img_destination_direction; visible: false }
        }

	]
}
