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
    property real total_distance: 0

    onSts_guideChanged: {
        console.log("onSts_guideChanged")
        switch(btn_guidance.sts_guide){
        case 0:
            if (root.st_demo_state === true){
                positionTimer.stop();
            }
            break
        case 1:
            break
        case 2:
            if (root.st_demo_state === true){
                positionTimer.start();
            }
            break
        default:
            break
        }
    }

    function startGuidance() {
        btn_present_position.state = "Flowing"
        btn_guidance.sts_guide = 2
        btn_guidance.state = "onGuide"
        map.addStartPoint()
        if (root.st_demo_state === false){
            if (routeModel.count > 0){
                for (var i = 0; i < routeModel.get(0).segments.length; i++)
                {
                    btn_guidance.total_distance +=routeModel.get(0).segments[i].maneuver.distanceToNextInstruction
                    // console.log("navi: segmentcounter i:"+i+" distance:"+routeModel.get(0).segments[i].maneuver.distanceToNextInstruction)
                }
                // console.log("navi: segmentcounter total_distance"+btn_guidance.total_distance)
            }
            root.setdistance(btn_guidance.total_distance,0)
            root.do_startguidance()
        }
    }

    function stopGuidance() {
//        map.initDestination(map.currentpostion)
        map.resetDestination()

        if(btn_guidance.sts_guide != 0){
            root.do_stopdemo()
        }

        if(map.center !== map.currentpostion){
            btn_present_position.state = "Optional"
        }

        btn_guidance.sts_guide = 0
        btn_guidance.state = "Idle"
    }

    function discardWaypoints(startFromCurrentPosition) {
        if (startFromCurrentPosition === undefined) startFromCurrentPosition = false
        map.initDestination(startFromCurrentPosition)

        if(btn_guidance.sts_guide != 0){
            root.do_stopdemo()
        }

        if(map.center !== map.currentpostion){
            btn_present_position.state = "Optional"
        }

        btn_guidance.sts_guide = 0
        btn_guidance.state = "Idle"
        if (root.st_demo_state === false){
            root.setdistance(btn_guidance.total_distance,0)
            root.do_cancelguidance()
        }
    }

    Timer {
        id: positionTimer
        interval: fileOperation.getUpdateInterval();
        running: false;
        repeat: true
        onTriggered: map.updateDemoPositon()
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
            source: "images/MUTCD_RS-113.svg"
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
