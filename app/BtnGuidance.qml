import QtQuick 2.0
import QtQuick.Controls 1.5
import QtLocation 5.9
import QtPositioning 5.6

Item {
    id: btn_guidance

    // 0: idle
    // 1: routing
    // 2: on guide
    property int sts_guide: 0

    onSts_guideChanged: {
        console.log("onSts_guideChanged")
        switch(btn_guidance.sts_guide){
        case 0:
            positionTimer.stop();
            break
        case 1:
            break
        case 2:
            positionTimer.start();
            break
        default:
            break
        }
    }

    function startGuidance() {
        btn_present_position.state = "Flowing"
        btn_guidance.sts_guide = 2
        btn_guidance.state = "onGuide"
    }

    function discardWaypoints() {
        map.initDestination()

        if(btn_guidance.sts_guide != 0){
            map.qmlSignalStopDemo()
        }

        if(map.center !== map.currentpostion){
            btn_present_position.state = "Optional"
        }

        btn_guidance.sts_guide = 0
        btn_guidance.state = "Idle"
    }

    Timer {
        id: positionTimer
        interval: fileOperation.getUpdateInterval();
        running: false;
        repeat: true
        onTriggered: map.updatePositon()
    }

    Button {
        id: discard
        width: 100
        height: 100

        visible: false

        onClicked: discardWaypoints()

        Image {
            id: discard_image
            width: 92
            height: 92
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/200px-Black_close_x.svg.png"
        }
    }

    Button {
        id: guidance
		width: 100
		height: 100

        visible: false

        onClicked: { startGuidance() }

		Image {
            id: guidance_image
			width: 92
			height: 92
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
            source: "images/124px-Pictograms-nps-land-driving_tour-2.svg.png"
		}

	}
    states: [
        State {
            name: "Idle"
            PropertyChanges { target: discard; visible: false }
            PropertyChanges { target: guidance; visible: false }
            PropertyChanges { target: guidance; x: 0 }
            PropertyChanges { target: progress_next_cross; state: "invisible" }
            PropertyChanges { target: img_destination_direction; state: "invisible" }
        },
        State {
            name: "Routing"
            PropertyChanges { target: discard; visible: true }
            PropertyChanges { target: guidance; visible: true }
            PropertyChanges { target: guidance; x: -150 }
            PropertyChanges { target: progress_next_cross; state: "invisible" }
            PropertyChanges { target: img_destination_direction; state: "invisible" }
        },
        State {
            name: "onGuide"
            PropertyChanges { target: discard; visible: true }
            PropertyChanges { target: guidance; visible: false }
            PropertyChanges { target: guidance; x: 0 }
            PropertyChanges { target: progress_next_cross; state: "visible" }
            PropertyChanges { target: img_destination_direction; state: "0" }
        }
    ]

    transitions: Transition {
        NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad }
        NumberAnimation { properties: "visible"; easing.type: Easing.InOutQuad }
    }
}
