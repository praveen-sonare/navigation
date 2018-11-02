import QtLocation 5.9
import QtPositioning 5.0
import QtQuick 2.0

import com.mapbox.cheap_ruler 1.0

Item {
    id: mapWindow

    // Km/h
    property int carSpeed: 180
    property bool navigating: false

    property real rotateAngle: 0
    property var startPoint: QtPositioning.coordinate(36.12549, -115.173498)
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

    Image {
        id: backgroud
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 100

        source: "qrc:simple-bottom-background-white.png"
        z: 1
    }

    Image {
        id: carCurrent
        anchors.left: parent.left
        anchors.top: parent.top
        z: 3

        visible: !mapWindow.navigating
        source: "qrc:car-focus.png"

        MouseArea {
            id: area

            anchors.fill: parent

            onClicked: {
                mapWindow.navigating = true
                currentDistanceAnimation.start();
            }
        }

        scale: area.pressed ? 0.85 : 1.0

        Behavior on scale {
            NumberAnimation {}
        }
    }

    Image {
        id: turnDirection
        anchors.left: carCurrent.right
        anchors.top: parent.top
        anchors.leftMargin: 20

        z: 3
    }

    CustomLabel {
        id: distance
        anchors.left: carCurrent.right
        anchors.bottom: backgroud.bottom
        z: 3

        font.pixelSize: 38
    }

    CustomLabel {
        id: turnInstructions
        anchors.left: turnDirection.right
        anchors.top: parent.top
        anchors.leftMargin: 30
        anchors.topMargin: (backgroud.height-turnInstructions.height)/2
        z: 3

        font.pixelSize: 38
    }

    Map {
        id: map
        anchors.fill: parent

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

        center: mapWindow.navigating ? ruler.currentPosition : startPoint
        zoomLevel: 5
        minimumZoomLevel: 0
        maximumZoomLevel: 20
        tilt: 0

        copyrightsVisible: false

        MouseArea {
            anchors.fill: parent

            onWheel: {
                mapWindow.navigating = false
                wheel.accepted = false
            }
        }
        gesture.onPanStarted: {
            mapWindow.navigating = false
        }

        gesture.onPinchStarted: {
            mapWindow.navigating = false
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
                    ruler.currentDistance = 0;

                    currentDistanceAnimation.stop();
                    currentDistanceAnimation.to = ruler.distance;
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

            PropertyAnimation on currentDistance {
                id: currentDistanceAnimation

                duration: ruler.distance / mapWindow.carSpeed * 60 * 60 * 1000
                alwaysRunToEnd: false
            }

            onCurrentDistanceChanged: {
                var total = 0;
                var total2 = 0;
                var i = 0;
                var j = 0;
                var alltime = routeModel.get(0).travelTime;
                var alldistance = routeModel.get(0).distance;

                // XXX: Use car speed in meters to pre-warn the turn instruction
                while (total - mapWindow.carSpeed < ruler.currentDistance * 1000 && i < routeModel.get(0).segments.length)
                {
                    total += routeModel.get(0).segments[i++].maneuver.distanceToNextInstruction;
                }

                while (total2 < ruler.currentDistance * 1000 && j < routeModel.get(0).segments.length)
                {
                    total2 += routeModel.get(0).segments[j++].maneuver.distanceToNextInstruction;
                }

                var dis = (total2 - ruler.currentDistance * 1000).toFixed(1);
                if(dis > 1000)
                {
                    distance.text = (dis / 1000).toFixed(1) + " km";
                }
                else
                {
                    distance.text = dis + " m";
                }

                var travaltimesec=((1 - (ruler.currentDistance * 1000)/alldistance)*alltime).toFixed(0);

                if((travaltimesec/3600)>=1)
                {
                    travaltime.text = (travaltimesec/3600).toFixed(0) + "h" + ((travaltimesec%3600)/60).toFixed(0) + "min";
                }
                else
                {
                    travaltime.text = (travaltimesec/60).toFixed(0) + "min";
                }

                turnInstructions.text = routeModel.get(0).segments[i - 1].maneuver.instructionText;

                if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionForward)
                {
                    turnDirection.source = "qrc:arrow-0.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLightRight)
                {
                    turnDirection.source = "qrc:arrow-r-30.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionRight)
                {
                    turnDirection.source = "qrc:arrow-r-45.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionHardRight)
                {
                    turnDirection.source = "qrc:arrow-r-75.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionUTurnRight)
                {
                    turnDirection.source = "qrc:arrow-r-180.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLightLeft)
                {
                    turnDirection.source = "qrc:arrow-l-30.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionLeft)
                {
                    turnDirection.source = "qrc:arrow-l-45.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionHardLeft)
                {
                    turnDirection.source = "qrc:arrow-l-75.png";
                }
                else if(routeModel.get(0).segments[i - 1].maneuver.direction === RouteManeuver.DirectionUTurnLeft)
                {
                    turnDirection.source = "qrc:arrow-l-180.png";
                }
                else
                {
                    turnDirection.source = "qrc:arrow-0.png";
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
        width: parent.width
        height: 100

        source: "qrc:simple-bottom-background-white.png"
        z: 1
    }

    CustomLabel {
        id: travaltime
        anchors.left: bottombackgroud.left
        anchors.verticalCenter: bottombackgroud.verticalCenter
        visible: mapWindow.navigating
        z: 3
        font.pixelSize: 38
    }

    Row {
        anchors.horizontalCenter: bottombackgroud.horizontalCenter
        anchors.verticalCenter: bottombackgroud.verticalCenter
        width: bottombackgroud.width / 4
        spacing: 10
        z:3
        DateAndTime {}
    }
}
