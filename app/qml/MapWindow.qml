import QtLocation 5.9
import QtPositioning 5.0
import QtQuick 2.0

import com.mapbox.cheap_ruler 1.0

Item {
    id: mapWindow

    property int disOffset: 70
    property real rotateAngle: 0
    property var startPoint
    property var endPoint

    //turn by turn board view
    TbtBoard {
        id: tbt_board
        z: 1
        visible: false
        anchors.fill: parent
    }

    //mapview and route views
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
                value: "pk.eyJ1IjoiaW5zZXJ0MDAwMyIsImEiOiJjam94dTFzanYyNWFpM3ZrZmp4bXhlcDh6In0.2aQLdVtA5LsHgSQiarz7vw"
            }

            PluginParameter {
                name: "mapboxgl.mapping.cache.directory"
                value: "/home/0/app-data/navigation/"
            }
        }

        center: ruler.currentPosition
        zoomLevel: 20
        tilt: 60
        gesture.acceptedGestures:MapGestureArea.NoGesture
        copyrightsVisible: false

        RotationAnimation on bearing {
            id: bearingAnimation

            duration: 250
            alwaysRunToEnd: false
            direction: RotationAnimation.Shortest
            running: true
        }

        Location {
            id: previousLocation
            coordinate: QtPositioning.coordinate(0, 0);
        }

        onCenterChanged: {
            if (previousLocation.coordinate === center)
                return;

            bearingAnimation.to = previousLocation.coordinate.azimuthTo(center);
            bearingAnimation.start();

            previousLocation.coordinate = center;
        }

        MapQuickItem {
            id: startMarker

            sourceItem: Image {
                id: greenMarker
                source: "qrc:///marker-green.png"
            }
            anchorPoint.x: greenMarker.width / 2
            anchorPoint.y: greenMarker.height / 2
        }

        MapQuickItem {
            id: endMarker

            sourceItem: Image {
                id: redMarker
                source: "qrc:///marker-end.png"
            }
            anchorPoint.x: redMarker.width / 2
            anchorPoint.y: redMarker.height / 2
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
                source: "qrc:///car-marker.png"
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

        //add route view in the map
        function updateRoute() {
            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(startMarker.coordinate);
            routeQuery.addWaypoint(endMarker.coordinate);
            map.addMapItem(startMarker)
            map.addMapItem(endMarker)
        }

        //clear route view in the map
        function clearRoute() {
            routeQuery.clearWaypoints();
            routeModel.reset();
            map.removeMapItem(startMarker)
            map.removeMapItem(endMarker)
        }

        CheapRuler {
            id: ruler

            onCurrentDistanceChanged: {
                var total = 0;
                var i = 0;
                var alldistance = ruler.distance * 1000;

                if((routeModel.status === RouteModel.Ready)
                && (routeModel.count === 1))
                {
                    // XXX: Use car speed in meters to pre-warn the turn instruction
                    while (total < ruler.currentDistance && i < routeModel.get(0).segments.length)
                    {
                        total += routeModel.get(0).segments[i++].maneuver.distanceToNextInstruction;
                    }

                    //show the tbt board(it will be always show when demo start)
                    tbt_board.visible = true

                     // Set turn instruction
                    tbt_board.do_setTurnInstructions(routeModel.get(0).segments[i].maneuver.instructionText)
                    tbt_board.state = routeModel.get(0).segments[i].maneuver.direction

                    //when goto the last instruction,set the states to "arriveDest"
                    if(i >= (routeModel.get(0).segments.length-1))
                    {
                        total = alldistance;
                        tbt_board.state = "arriveDest";
                    }

                    var dis = (total - ruler.currentDistance).toFixed(1);

                    // Set distance
                    tbt_board.do_setDistance(dis)

                     // Set board status
                    if(dis < mapWindow.disOffset && i < routeModel.get(0).segments.length)
                    {
                        //show the tbt board(the big one)
                        tbt_board.do_showTbtboard(true)
                     }
                    else
                    {
                        //disvisible the tbt board(the big one)
                        tbt_board.do_showTbtboard(false)
                    }
                }
            }
        }
    }

    //the route view display by RouteModel
    RouteModel {
        id: routeModel

        autoUpdate: true
        query: routeQuery

        plugin: Plugin {
            name: "mapbox"

            // Development access token, do not use in production.
            PluginParameter {
                name: "mapbox.access_token"
                value: "pk.eyJ1IjoiaW5zZXJ0MDAwMyIsImEiOiJjam94dTFzanYyNWFpM3ZrZmp4bXhlcDh6In0.2aQLdVtA5LsHgSQiarz7vw"
            }
        }
    }

    RouteQuery {
        id: routeQuery
    }

    Component.onCompleted: {
        //request the route info when map load finish
        if (ruler) {
            ruler.initRouteInfo();
        }
    }

    //the functions can be called by outside
    //add route signal function
    function do_addRoutePoint(poi_Lat_s, poi_Lon_s, poi_Lat_e, poi_Lon_e) {
        //set the startPoint and endPoint
        startPoint= QtPositioning.coordinate(poi_Lat_s,poi_Lon_s);
        endPoint = QtPositioning.coordinate(poi_Lat_e,poi_Lon_e);
        startMarker.coordinate = startPoint;
        endMarker.coordinate = endPoint;
        //update the route view
        if (map) {
            map.updateRoute();
        }
    }

    //set the current position
    function do_setCoordinate(latitude,longitude,direction,distance) {
        ruler.setCurrentPosition(latitude, longitude, distance);
    }

    //stop navidemo signal
    function do_stopnavidemo() {
        //disvisible the tbt board
        tbt_board.visible = false
        //clear the routeview
        if (map) {
            map.clearRoute();
        }
    }

    //arrvice the destination signal
    function do_arrivedest(){
        //disvisible the tbt board
        tbt_board.visible = false
    }
}
