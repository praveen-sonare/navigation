import QtLocation 5.9
import QtPositioning 5.0
import QtQuick 2.0

import com.mapbox.cheap_ruler 1.0

Item {
    id: mapWindow

    // Km/h
    property int carSpeed: 70
    property bool navigating: false
    property bool zoomstate: false

    property real rotateAngle: 0
    property var startPoint: QtPositioning.coordinate(36.12546,-115.173)
    property var endPoint: QtPositioning.coordinate(36.0659063, -115.1800443)

    states: [
        State {
            name: ""
            PropertyChanges { target: map; tilt: 0; bearing: 0; zoomLevel: map.zoomLevel }
        },
        State {
            name: "navigating"
            PropertyChanges { target: map; tilt: 60; zoomLevel: 20 }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            RotationAnimation { target: map; property: "bearing"; duration: 100; direction: RotationAnimation.Shortest }
            NumberAnimation { target: map; property: "zoomLevel"; duration: 100 }
            NumberAnimation { target: map; property: "tilt"; duration: 100 }
        }
    ]

    state: navigating ? "navigating" : ""

    // Direction board
    Image {
        id: backgroudBoard

        anchors.fill: parent
        visible: map.showBoard
        source: "qrc:simple-bottom-background-black.png"
        z: 1
    }

    Image {
        id: turnDirectionBoard

        anchors.bottom: distanceBoard.top
        visible: map.showDirection
        width : parent.height - turnInstructionsBoard.height - distanceBoard.height
        height: parent.height - turnInstructionsBoard.height - distanceBoard.height
        z: 3
    }

    CustomLabel {
        id: distanceBoard

        anchors.bottom: turnInstructionsBoard.top
        z: 3
        visible: map.showDirection
        font.pixelSize: 45
        color: "#FFFFFF"
        width:backgroudBoard.width
        horizontalAlignment: Text.AlignHCenter
    }

    CustomLabel {
        id: turnInstructionsBoard

        anchors.bottom: parent.bottom
        z: 3
        visible: map.showDirection
        font.pixelSize: 30
        color: "#FFFFFF"
        width:backgroudBoard.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    CustomLabel {
        id: naviDoneBoard

        anchors.bottom: parent.bottom
        z: 3
        visible: map.showNaviDone
        font.pixelSize: 38
        color: "#FFFFFF"
        text: "Arrive destination.Auto Navi will restart in 5 seconds."
    }

    Map {
        id: map
        anchors.fill: parent

        property bool showBoard: false
        property bool showDirection: false
        property bool showNaviDone: false

        plugin: Plugin {
            name: "mapboxgl"

            PluginParameter {
                name: "mapboxgl.mapping.items.insert_before"
                value: "road-label-small"
            }

            PluginParameter {
                name: "mapboxgl.mapping.additional_style_urls"
                value: "mapbox://styles/mapbox/streets-v9"
            }

            PluginParameter {
                name: "mapboxgl.access_token"
                value: "pk.eyJ1IjoidG1wc2FudG9zIiwiYSI6ImNqMWVzZWthbDAwMGIyd3M3ZDR0aXl3cnkifQ.FNxMeWCZgmujeiHjl44G9Q"
            }

            PluginParameter {
                name: "mapboxgl.mapping.cache.directory"
                value: "/home/0/app-data/navigation/"
            }
        }

        center: (mapWindow.navigating && !mapWindow.zoomstate) ? ruler.currentPosition : startPoint
        zoomLevel: 12
        minimumZoomLevel: 0
        maximumZoomLevel: 20
        tilt: 0

        copyrightsVisible: false

        MouseArea {
            anchors.fill: parent

            onWheel: {
                mapWindow.zoomstate = true
                wheel.accepted = false
            }
        }
        gesture.onPanStarted: {
            mapWindow.zoomstate = true
        }

        gesture.onPinchStarted: {
            mapWindow.zoomstate = true
        }

        RotationAnimation on bearing {
            id: bearingAnimation

            duration: 250
            alwaysRunToEnd: false
            direction: RotationAnimation.Shortest
            running: mapWindow.navigating
        }

        Location {
            id: previousLocation
            coordinate: QtPositioning.coordinate(0, 0);
        }

        onCenterChanged: {
            if (previousLocation.coordinate === center || !mapWindow.navigating)
                return;

            bearingAnimation.to = previousLocation.coordinate.azimuthTo(center);
            bearingAnimation.start();

            previousLocation.coordinate = center;
        }

        function updateRoute() {
            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(startMarker.coordinate);
            routeQuery.addWaypoint(endMarker.coordinate);
        }

        MapQuickItem {
            id: startMarker

            sourceItem: Image {
                id: greenMarker
                source: "qrc:///marker-green.png"
            }

            coordinate : startPoint
            anchorPoint.x: greenMarker.width / 2
            anchorPoint.y: greenMarker.height / 2

            MouseArea  {
                drag.target: parent
                anchors.fill: parent

                onReleased: {
                    map.updateRoute();
                }
            }
        }

        MapQuickItem {
            id: endMarker

            sourceItem: Image {
                id: redMarker
                source: "qrc:///marker-end.png"
            }

            coordinate : endPoint
            anchorPoint.x: redMarker.width / 2
            anchorPoint.y: redMarker.height / 2

            MouseArea  {
                drag.target: parent
                anchors.fill: parent

                onReleased: {
                    map.updateRoute();
                }
            }
        }

        MapItemView {
            model: routeModel

            delegate: MapRoute {
                route: routeData
                line.color: "#6b43a1"
                line.width: map.zoomLevel - 5
                opacity: (index == 0) ? 1.0 : 0.3

                onRouteChanged: {
                    ruler.path = routeData.path;
                }
            }
        }

        MapQuickItem {
            zoomLevel: map.zoomLevel

            sourceItem: Image {
                id: carMarker
                source: "qrc:///car-marker2.png"
                transform: Rotation {
                                origin.x: carMarker.width / 2;
                                origin.y: carMarker.height / 2;
                                angle: rotateAngle
                            }
            }

            coordinate: ruler.currentPosition
            anchorPoint.x: carMarker.width / 2
            anchorPoint.y: carMarker.height / 2

            Location {
                id: previousCarLocation
                coordinate: QtPositioning.coordinate(0, 0);
            }

            onCoordinateChanged: {
                if(coordinate === mapWindow.startPoint)
                    return;
                rotateAngle = previousCarLocation.coordinate.azimuthTo(coordinate);
                previousCarLocation.coordinate = coordinate;
            }
        }

        CheapRuler {
            id: ruler

            onArrivedDest:
            {
                map.showBoard = true;
                map.showDirection = false;
                map.showNaviDone = true;
                restartnaviDemo.start()
            }

            onCurrentDistanceChanged: {
                var total = 0;
                var total2 = 0;
                var i = 0;
                var j = 0;
                var alltime = routeModel.get(0).travelTime;
                var alldistance = ruler.distance*1000;

                // XXX: Use car speed in meters to pre-warn the turn instruction
                while (total - mapWindow.carSpeed < ruler.currentDistance * 1000 && i < routeModel.get(0).segments.length)
                {
                    total += routeModel.get(0).segments[i++].maneuver.distanceToNextInstruction;
                }

                if(i >= routeModel.get(0).segments.length)
                {
                    total = alldistance;
                }

                while (total2 < ruler.currentDistance * 1000 && j < routeModel.get(0).segments.length)
                {
                    total2 += routeModel.get(0).segments[j++].maneuver.distanceToNextInstruction;
                }

                if(j >= routeModel.get(0).segments.length)
                {
                    total2 = alldistance;
                }

                var dis = (total2 - ruler.currentDistance * 1000).toFixed(1);

                 // Set board status
                if(dis < mapWindow.carSpeed && i < routeModel.get(0).segments.length)
                {
                    map.showBoard = true;
                    map.showDirection = true;
                    map.showNaviDone = false;
                }
                else
                {
                    map.showBoard = false;
                    map.showDirection = false;
                    map.showNaviDone = false;
                }

                // Set distance
                if(dis > 1000)
                {
                    distanceBoard.text = (dis / 1000).toFixed(1) + " km";
                }
                else
                {
                    distanceBoard.text = dis + " m";
                }

                // Set traval time
                var travaltimesec=((1 - (ruler.currentDistance * 1000)/alldistance)*alltime).toFixed(0);

                if((travaltimesec/3600)>=1)
                {
                    travaltime.text = (travaltimesec/3600).toFixed(0) + "h" + ((travaltimesec%3600)/60).toFixed(0) + "min";
                }
                else
                {
                    travaltime.text = (travaltimesec/60).toFixed(0) + "min";
                }

                // Set turn instruction
                turnInstructionsBoard.text = routeModel.get(0).segments[i - 1].maneuver.instructionText;

                // Set turn direction
                if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionForward)
                {
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLightRight)
                {
                    turnDirectionBoard.source = "qrc:arrow-r-30-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionRight)
                {
                    turnDirectionBoard.source = "qrc:arrow-r-45-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionHardRight)
                {
                    turnDirectionBoard.source = "qrc:arrow-r-75-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionUTurnRight)
                {
                    //TODO modify qtlocation U-Turn best.For test, change app source.
                    turnDirectionBoard.source = "qrc:arrow-l-180-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLightLeft)
                {
                    turnDirectionBoard.source = "qrc:arrow-l-30-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLeft)
                {
                    turnDirectionBoard.source = "qrc:arrow-l-45-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionHardLeft)
                {
                    turnDirectionBoard.source = "qrc:arrow-l-75-full.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionUTurnLeft)
                {
                    //TODO modify qtlocation U-Turn best.For test, change app source.
                    turnDirectionBoard.source = "qrc:arrow-r-180-full.png";
                }
                else
                {
                }
            }
        }
    }

    RouteModel {
        id: routeModel

        autoUpdate: true
        query: routeQuery

        plugin: Plugin {
            name: "mapbox"

            // Development access token, do not use in production.
            PluginParameter {
                name: "mapbox.access_token"
                value: "pk.eyJ1IjoicXRzZGsiLCJhIjoiY2l5azV5MHh5MDAwdTMybzBybjUzZnhxYSJ9.9rfbeqPjX2BusLRDXHCOBA"
            }
        }

        Component.onCompleted: {
            if (map) {
                map.updateRoute();
            }
        }
    }

    RouteQuery {
        id: routeQuery
    }

    Image {
        id: bottombackgroud
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width:parent.width
        height: 100
        visible: mapWindow.navigating && !map.showBoard && !map.showDirection && !map.showNaviDone
        source: "qrc:simple-bottom-background-white.png"
        z: 1
    }

    Image {
        id: carCurrent
        anchors.left: bottombackgroud.left
        anchors.verticalCenter: bottombackgroud.verticalCenter
        z: 3

        visible: !(mapWindow.navigating && !mapWindow.zoomstate)
        source: "qrc:car-focus.png"

        MouseArea {
            id: area

            anchors.fill: parent

            onClicked: {
                mapWindow.zoomstate = false
                do_startnavidemo()
            }
        }

        scale: area.pressed ? 0.85 : 1.0

        Behavior on scale {
            NumberAnimation {}
        }
    }

    CustomLabel {
        id: travaltime
        anchors.left: carCurrent.right
        anchors.verticalCenter: bottombackgroud.verticalCenter
        visible: mapWindow.navigating && !map.showBoard && !map.showDirection && !map.showNaviDone 
        z: 3
        font.pixelSize: 38
    }

    Row {
        anchors.horizontalCenter: bottombackgroud.horizontalCenter
        anchors.verticalCenter: bottombackgroud.verticalCenter
        visible: mapWindow.navigating && !map.showBoard && !map.showDirection && !map.showNaviDone
        spacing: 10
        z:3
        DateAndTime {}
    }


    Image {
        id: stopdemo
        anchors.right: parent.right
        anchors.bottom:parent.bottom
        z: 3

        visible: mapWindow.navigating && !map.showBoard && !map.showDirection && !map.showNaviDone
        source: "qrc:car-marker.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                do_stopnavidemo();
            }

            onReleased: {
                map.updateRoute();
            }
        }
    }

    Timer {
        id: naviTimer
        repeat: false
        interval: 5000
        triggeredOnStart: false
        onTriggered: {
            console.log("onTriggered")
            do_startnavidemo()
            mapWindow.zoomstate = false

        }
    }

    Timer {
        id: restartnaviDemo
        repeat: false
        interval: 5000
        triggeredOnStart: false
        onTriggered: {
            console.log("onTriggered")
            do_stopnavidemo()
            map.updateRoute();
            mapWindow.zoomstate = false
            do_startnavidemo()
        }
    }

    function do_setCoordinate(latitude,longitude) {
        ruler.setCurrentCoordinate(latitude,longitude);
    }

    function do_startnavidemo() {
        if(mapWindow.navigating == false)
        {
            ruler.startnaviDemo()
            mapWindow.navigating = true
        }
    }

    function do_stopnavidemo() {
        if(mapWindow.navigating == true)
        {
            ruler.stopnaviDemo()
            mapWindow.navigating = false
        	ruler.setCurrentCoordinate("36.12546","-115.173");
        }
    }

    function do_autostart() {
        console.log("naviTimer start")
        naviTimer.start()
    }
}
