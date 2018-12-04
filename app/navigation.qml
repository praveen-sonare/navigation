/*
 * Copyright (C) 2016 The Qt Company Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtWebSockets 1.0
import QtLocation 5.9
import QtPositioning 5.6

ApplicationWindow {
	id: root
	visible: true
	width: 1080
    height: 1488
//    height: 680 //debug
	title: qsTr("navigation")

    property real car_position_lat: fileOperation.getStartLatitude()
    property real car_position_lon: fileOperation.getStartLongitute()
    property real car_direction: 0  //North
    property real car_driving_speed: fileOperation.getCarSpeed()  // set Km/h
    property real prev_car_direction: 0
    property bool st_heading_up: false
    property real default_zoom_level : 18
    property real default_car_direction : 0
    property real car_accumulated_distance : 0
    property real positionTimer_interval : fileOperation.getUpdateInterval() // set millisecond
    property real car_moving_distance : (car_driving_speed / 3.6) / (1000/positionTimer_interval) // Metric unit

    Map{
		id: map
        property int pathcounter : 0
        property int prevpathcounter : -1
        property real is_rotating: 0
        property int segmentcounter : 0
        property int waypoint_count: -1
		property int lastX : -1
		property int lastY : -1
		property int pressX : -1
		property int pressY : -1
		property int jitterThreshold : 30
        property variant currentpostion : QtPositioning.coordinate(car_position_lat, car_position_lon)
        property var poiArray: new Array
        property int last_segmentcounter : -1

        signal qmlSignalRouteInfo(double srt_lat,double srt_lon,double end_lat,double end_lon);
        signal qmlSignalPosInfo(double lat,double lon,double drc,double dst);
        signal qmlSignalStopDemo();
        signal qmlSignalArrvied();

        width: parent.width
        height: parent.height
		plugin: Plugin {
            name: "mapboxgl"
            PluginParameter { name: "mapboxgl.access_token";
            value: fileOperation.getMapAccessToken() }
		}
        center: QtPositioning.coordinate(car_position_lat, car_position_lon)
        zoomLevel: default_zoom_level
        bearing: 0
        objectName: "map"

		GeocodeModel {
			id: geocodeModel
			plugin: map.plugin
			onStatusChanged: {
				if ((status == GeocodeModel.Ready) || (status == GeocodeModel.Error))
					map.geocodeFinished()
			}
			onLocationsChanged:
			{
				if (count == 1) {
					map.center.latitude = get(0).coordinate.latitude
					map.center.longitude = get(0).coordinate.longitude
				}
			}
            //coordinate: poiTheQtComapny.coordinate
            //anchorPoint: Qt.point(-poiTheQtComapny.sourceItem.width * 0.5,poiTheQtComapny.sourceItem.height * 1.5)
        }
		MapItemView {
			model: geocodeModel
			delegate: pointDelegate
		}
		Component {
			id: pointDelegate

			MapCircle {
				id: point
				radius: 1000
				color: "#46a2da"
				border.color: "#190a33"
				border.width: 2
				smooth: true
				opacity: 0.25
				center: locationData.coordinate
			}
		}

		function geocode(fromAddress)
		{
			// send the geocode request
			geocodeModel.query = fromAddress
			geocodeModel.update()
		}
		
        MapQuickItem {
            id: poi
            sourceItem: Rectangle { width: 14; height: 14; color: "#e41e25"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
            coordinate {
                latitude: 36.136261
                longitude: -115.151254
            }
            opacity: 1.0
            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
        }
        MapQuickItem {
            sourceItem: Text{
                text: "Westgate"
                color:"#242424"
                font.bold: true
                styleColor: "#ECECEC"
                style: Text.Outline
            }
            coordinate: poi.coordinate
            anchorPoint: Qt.point(-poi.sourceItem.width * 0.5, poi.sourceItem.height * 1.5)
        }
        MapQuickItem {
            id: car_position_mapitem
            property int isRotating: 0
            sourceItem: Image {
                id: car_position_mapitem_image
                width: 32
                height: 32
                source: "images/240px-Red_Arrow_Up.svg.png"

                transform: Rotation {
                    id: car_position_mapitem_image_rotate
                    origin.x: car_position_mapitem_image.width/2
                    origin.y: car_position_mapitem_image.height/2
                    angle: car_direction
                }
            }
            anchorPoint: Qt.point(car_position_mapitem_image.width/2, car_position_mapitem_image.height/2)
            coordinate: map.currentpostion


            states: [
                State {
                    name: "HeadingUp"
                    PropertyChanges { target: car_position_mapitem_image_rotate; angle: 0 }
                },
                State {
                    name: "NorthUp"
                    PropertyChanges { target: car_position_mapitem_image_rotate; angle: root.car_direction }
                }
            ]
            transitions: Transition {
                RotationAnimation {
                    properties: "angle";
                    easing.type: Easing.InOutQuad;
                    direction: RotationAnimation.Shortest;
                    duration: 200
                }
            }
        }

        MapQuickItem {
            id: icon_start_point
            anchorPoint.x: icon_start_point_image.width/2
            anchorPoint.y: icon_start_point_image.height
            sourceItem: Image {
                id: icon_start_point_image
                width: 32
                height: 32
                source: "images/240px-HEB_project_flow_icon_04_checkered_flag.svg.png"
            }
        }

        MapQuickItem {
            id: icon_end_point
            anchorPoint.x: icon_end_point_image.width/2
            anchorPoint.y: icon_end_point_image.height
            sourceItem: Image {
                id: icon_end_point_image
                width: 32
                height: 32
                source: "images/Map_marker_icon_–_Nicolas_Mollet_–_Flag_–_Tourism_–_Classic.png"
            }
        }

        MapQuickItem {
            id: icon_segment_point
            anchorPoint.x: icon_segment_point_image.width/2 - 5
            anchorPoint.y: icon_segment_point_image.height/2 + 25
            sourceItem: Image {
                id: icon_segment_point_image
                width: 64
                height: 64
                source: "images/Map_symbol_location_02.png"
            }
        }

		RouteModel {
			id: routeModel
            plugin : Plugin {
                name: "mapbox"
                PluginParameter { name: "mapbox.access_token";
                    value: fileOperation.getMapAccessToken()
                }
            }
			query:  RouteQuery {
				id: routeQuery
			}
			onStatusChanged: {
				if (status == RouteModel.Ready) {
					switch (count) {
					case 0:
						// technically not an error
					//	map.routeError()
						break
					case 1:
						map.pathcounter = 0
                        map.prevpathcounter = -1
                        map.is_rotating = 0
						map.segmentcounter = 0
//						console.log("1 route found")
//						console.log("path: ", get(0).path.length, "segment: ", get(0).segments.length)
//						for(var i = 0; i < get(0).path.length; i++){
//							console.log("", get(0).path[i])
//						}
                        console.log("1st instruction: ", get(0).segments[map.segmentcounter].maneuver.instructionText)
                        for( var i = 0; i < routeModel.get(0).segments.length; i++){
                            console.log("segments[",i,"].maneuver.direction:" ,routeModel.get(0).segments[i].maneuver.direction)
                            console.log("segments[",i,"].maneuver.instructionText:" ,routeModel.get(0).segments[i].maneuver.instructionText)
                            console.log("segments[",i,"].maneuver.path[0]:" ,routeModel.get(0).segments[i].path[0].latitude,",",routeModel.get(0).segments[i].path[0].longitude)
//                            markerModel.addMarker(routeModel.get(0).segments[i].path[0]) // for debug
                        }
                        break
					}
				} else if (status == RouteModel.Error) {
				//	map.routeError()
				}
			}
		}
		
		Component {
			id: routeDelegate

			MapRoute {
				id: route
				route: routeData
				line.color: "#4658da"
				line.width: 10
				smooth: true
                opacity: 0.8
			}
		}
		
		MapItemView {
			model: routeModel
			delegate: routeDelegate
		}

        MapItemView{
            model: markerModel
            delegate: mapcomponent
        }

        Component {
            id: mapcomponent
            MapQuickItem {
                id: icon_destination_point
                anchorPoint.x: icon_destination_point_image.width/4
                anchorPoint.y: icon_destination_point_image.height
                coordinate: position

                sourceItem: Image {
                    id: icon_destination_point_image
                    width: 32
                    height: 32
                    source: "images/200px-Black_close_x.svg.png"
                }
            }
        }

        function addDestination(coord){
            if( waypoint_count < 0 ){
                initDestination()
            }

            if(waypoint_count == 0)  {
                // set icon_start_point
                icon_start_point.coordinate = currentpostion
                map.addMapItem(icon_start_point)
            }

            if(waypoint_count < 9){
                routeQuery.addWaypoint(coord)
                waypoint_count += 1

                btn_guidance.sts_guide = 1
                btn_guidance.state = "Routing"

                var waypointlist = routeQuery.waypoints
                for(var i=1; i<waypoint_count; i++) {
                    markerModel.addMarker(waypointlist[i])

//                    map.addPoiIconSLOT(waypointlist[i].latitude,waypointlist[i].longitude,i % 5) // for Debug
                }

                routeModel.update()
                map.qmlSignalRouteInfo(car_position_lat, car_position_lon,coord.latitude,coord.longitude)

                // update icon_end_point
                icon_end_point.coordinate = coord
                map.addMapItem(icon_end_point)
            }
        }

        function initDestination(){
            routeModel.reset();
            console.log("initWaypoint")

            // reset currentpostion
            map.currentpostion = QtPositioning.coordinate(car_position_lat, car_position_lon)
            car_accumulated_distance = 0
            map.qmlSignalPosInfo(car_position_lat, car_position_lon,car_direction,car_accumulated_distance)

            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(map.currentpostion)
            routeQuery.travelModes = RouteQuery.CarTravel
            routeQuery.routeOptimizations = RouteQuery.FastestRoute
            for (var i=0; i<9; i++) {
                routeQuery.setFeatureWeight(i, 0)
            }
            waypoint_count = 0
            pathcounter = 0
            prevpathcounter = -1
            is_rotating = 0
            segmentcounter = 0
            routeModel.update();
            markerModel.removeMarker();
            map.removeMapItem(markerModel);

            // remove MapItem
            map.removeMapItem(icon_start_point)
            map.removeMapItem(icon_end_point)
            map.removeMapItem(icon_segment_point)

            // for Debug
//            while(poiArray.length>0)
//                map.removeMapItem(poiArray.pop())

            // update car_position_mapitem angle
            root.car_direction = root.default_car_direction

        }

		function calculateMarkerRoute()
		{
            var startCoordinate = QtPositioning.coordinate(car_position_lat, car_position_lon)

			console.log("calculateMarkerRoute")
			routeQuery.clearWaypoints();
            routeQuery.addWaypoint(startCoordinate)
            routeQuery.addWaypoint(mouseArea.lastCoordinate)
			routeQuery.travelModes = RouteQuery.CarTravel
			routeQuery.routeOptimizations = RouteQuery.FastestRoute
			for (var i=0; i<9; i++) {
				routeQuery.setFeatureWeight(i, 0)
			}
			routeModel.update();
		}

        // Calculate direction from latitude and longitude between two points
        function calculateDirection(lat1, lon1, lat2, lon2) {
            var curlat = lat1 * Math.PI / 180;
            var curlon = lon1 * Math.PI / 180;
            var taglat = lat2 * Math.PI / 180;
            var taglon = lon2 * Math.PI / 180;

            var Y  = Math.sin(taglon - curlon);
            var X  = Math.cos(curlat) * Math.tan(taglat) - Math.sin(curlat) * Math.cos(Y);
            var direction = 180 * Math.atan2(Y,X) / Math.PI;
            if (direction < 0) {
              direction = direction + 360;
            }
            return direction;
        }

        // Calculate distance from latitude and longitude between two points
        function calculateDistance(lat1, lon1, lat2, lon2)
        {
            var radLat1 = lat1 * Math.PI / 180;
            var radLon1 = lon1 * Math.PI / 180;
            var radLat2 = lat2 * Math.PI / 180;
            var radLon2 = lon2 * Math.PI / 180;

            var r = 6378137.0;

            var averageLat = (radLat1 - radLat2) / 2;
            var averageLon = (radLon1 - radLon2) / 2;
            var result = r * 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(averageLat), 2) + Math.cos(radLat1) * Math.cos(radLat2) * Math.pow(Math.sin(averageLon), 2)));
            return Math.round(result);
        }

        // Setting the next car position from the direction and demonstration mileage
        function setNextCoordinate(curlat,curlon,direction,distance)
        {
            var radian = direction * Math.PI / 180
            var lat_per_meter = 111319.49079327358;
            var lat_distance = distance * Math.cos(radian);
            var addlat = lat_distance / lat_per_meter
            var lon_distance = distance * Math.sin(radian)
            var lon_per_meter = (Math.cos( (curlat+addlat) / 180 * Math.PI) * 2 * Math.PI * 6378137) / 360;
            var addlon = lon_distance / lon_per_meter
            map.currentpostion = QtPositioning.coordinate(curlat+addlat, curlon+addlon);
        }

        function addPoiIconSLOT(lat,lon,type) {
            console.log("called addPoiIcon")
            var poiItem;
            switch(type){
                case 0:
                    poiItem = Qt.createQmlObject("
                            import QtQuick 2.0;
                            import QtLocation 5.9;
                            MapQuickItem {
                                id: poi_icon;
                                anchorPoint.x: icon_flag_liteblue_image.width/2;
                                anchorPoint.y: icon_flag_liteblue_image.height;
                                sourceItem: Image {
                                    id: icon_flag_liteblue_image;
                                    width: 32;
                                    height: 37;
                                    source: \"images/Flag-export_lightblue.png\";
                                }
                            }
                        ",map,"dynamic");
                    break;
                case 1:
                    poiItem = Qt.createQmlObject("
                            import QtQuick 2.0;
                            import QtLocation 5.9;
                            MapQuickItem {
                                id: poi_icon;
                                anchorPoint.x: icon_building_image.width/2;
                                anchorPoint.y: icon_building_image.height;
                                sourceItem: Image {
                                    id: icon_building_image;
                                    width: 32;
                                    height: 37;
                                    source: \"images/BuildingIcon.png\";
                                }
                            }
                        ",map,"dynamic");
                    break;
                case 2:
                    poiItem = Qt.createQmlObject("
                            import QtQuick 2.0;
                            import QtLocation 5.9;
                            MapQuickItem {
                                id: poi_icon;
                                anchorPoint.x: icon_church_image.width/2;
                                anchorPoint.y: icon_church_image.height;
                                sourceItem: Image {
                                    id: icon_church_image;
                                    width: 32;
                                    height: 37;
                                    source: \"images/ChurchIcon.png\";
                                }
                            }
                        ",map,"dynamic");
                    break;
                case 3:
                    poiItem = Qt.createQmlObject("
                            import QtQuick 2.0;
                            import QtLocation 5.9;
                            MapQuickItem {
                                id: poi_icon;
                                anchorPoint.x: icon_restaurant_image.width/2;
                                anchorPoint.y: icon_restaurant_image.height;
                                sourceItem: Image {
                                    id: icon_restaurant_image;
                                    width: 32;
                                    height: 37;
                                    source: \"images/RestaurantMapIcon.png\";
                                }
                            }
                        ",map,"dynamic");
                    break;
                case 4:
                    poiItem = Qt.createQmlObject("
                            import QtQuick 2.0;
                            import QtLocation 5.9;
                            MapQuickItem {
                                id: poi_icon;
                                anchorPoint.x: icon_supermarket_image.width/2;
                                anchorPoint.y: icon_supermarket_image.height;
                                sourceItem: Image {
                                    id: icon_supermarket_image;
                                    width: 32;
                                    height: 37;
                                    source: \"images/SupermarketMapIcon.png\";
                                }
                            }
                        ",map,"dynamic");
                    break;
                default:
                    poiItem = null;
                    break;
            }

            if(poiItem === null) {
               console.log("error creating object" +  poiItem.errorString());
               return false;
            }

            poiItem.coordinate = QtPositioning.coordinate(lat, lon);
            map.addMapItem(poiItem);
            poiArray.push(poiItem);
//            console.log("success creating object");
            return true;
        }

		MouseArea {
			id: mouseArea
			property variant lastCoordinate
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			
			onPressed : {
				map.lastX = mouse.x
				map.lastY = mouse.y
				map.pressX = mouse.x
				map.pressY = mouse.y
				lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
			}
			
			onPositionChanged: {
                if (mouse.button === Qt.LeftButton) {
					map.lastX = mouse.x
					map.lastY = mouse.y
				}
			}
			
			onPressAndHold:{
                if((btn_guidance.state !== "onGuide") && (btn_guidance.state !== "Routing"))
                {
                    if (Math.abs(map.pressX - mouse.x ) < map.jitterThreshold
                            && Math.abs(map.pressY - mouse.y ) < map.jitterThreshold) {
                        map.addDestination(lastCoordinate)
                    }
                }

			}
		}
        gesture.onFlickStarted: {
            btn_present_position.state = "Optional"
        }
        gesture.onPanStarted: {
            btn_present_position.state = "Optional"
        }
		function updatePositon()
		{
//			console.log("updatePositon")
            if(pathcounter <= routeModel.get(0).path.length - 1){
//                console.log("path: ", pathcounter, "/", routeModel.get(0).path.length - 1, " segment: ", segmentcounter, "/", routeModel.get(0).segments.length - 1)
//                console.log("from_to:",map.currentpostion.latitude,",",map.currentpostion.longitude,",",routeModel.get(0).path[pathcounter].latitude,",",routeModel.get(0).path[pathcounter].longitude)
                // calculate distance
                var next_distance = calculateDistance(map.currentpostion.latitude,
                                                      map.currentpostion.longitude,
                                                      routeModel.get(0).path[pathcounter].latitude,
                                                      routeModel.get(0).path[pathcounter].longitude);
//                console.log("next_distance:",next_distance);

                // calculate direction
                var next_direction = calculateDirection(map.currentpostion.latitude,
                                                        map.currentpostion.longitude,
                                                        routeModel.get(0).path[pathcounter].latitude,
                                                        routeModel.get(0).path[pathcounter].longitude);
//                console.log("next_direction:",next_direction);

                // calculate next cross distance
                var next_cross_distance = calculateDistance(map.currentpostion.latitude,
                                                            map.currentpostion.longitude,
                                                            routeModel.get(0).segments[segmentcounter].path[0].latitude,
                                                            routeModel.get(0).segments[segmentcounter].path[0].longitude);
//                console.log("next_cross_distance:",next_cross_distance);

                // car_position_mapitem angle
                if(prevpathcounter !== pathcounter) {
                    root.prev_car_direction = root.car_direction
                    root.car_direction = next_direction
                }

                if(root.st_heading_up) {
                    // HeadingUp
                    is_rotating = map.bearing - root.car_direction;
                } else {
                    // NorthUp
                    is_rotating = root.prev_car_direction - root.car_direction;
                }

                if(is_rotating < 0) {
                    var val = -1;
                    is_rotating = is_rotating * val;
                }

                if(is_rotating < 30) {
                    // set next coordidnate
                    if(next_distance < (root.car_moving_distance * 1.5))
                    {
                        map.currentpostion = routeModel.get(0).path[pathcounter]
                        car_accumulated_distance += next_distance
                        map.qmlSignalPosInfo(map.currentpostion.latitude, map.currentpostion.longitude,next_direction,car_accumulated_distance)
                        if(pathcounter < routeModel.get(0).path.length - 1){
                            prevpathcounter = pathcounter
                            pathcounter++
                        }
                        else
                        {
                            // Arrive at your destination
                            btn_guidance.sts_guide = 0
                            map.qmlSignalArrvied()
                        }
                    }else{
                        setNextCoordinate(map.currentpostion.latitude, map.currentpostion.longitude,next_direction,root.car_moving_distance)
                        if(pathcounter != 0){
                            car_accumulated_distance += root.car_moving_distance
                        }
                        map.qmlSignalPosInfo(map.currentpostion.latitude, map.currentpostion.longitude,next_direction,car_accumulated_distance)
                    }
    //                console.log("NextCoordinate:",map.currentpostion.latitude,",",map.currentpostion.longitude)
                }

                if(btn_present_position.state === "Flowing")
                {
                    // update map.center
                    map.center = map.currentpostion
                }
                rotateMapSmooth()

                if(is_rotating < 30) {
                    // report a new instruction if current position matches with the head position of the segment
                    if(segmentcounter <= routeModel.get(0).segments.length - 1){
                         if(next_cross_distance < 2){
                            console.log("new segment instruction: ", routeModel.get(0).segments[segmentcounter].maneuver.instructionText) // for segment debug
                            progress_next_cross.setProgress(0)
                            if(segmentcounter < routeModel.get(0).segments.length - 1){
                                segmentcounter++
                            }
                            if(segmentcounter === routeModel.get(0).segments.length - 1){
                                img_destination_direction.state = "12"
                                map.removeMapItem(icon_segment_point)
                            }else{
                                img_destination_direction.state = routeModel.get(0).segments[segmentcounter].maneuver.direction
                                icon_segment_point.coordinate = routeModel.get(0).segments[segmentcounter].path[0]
                                map.addMapItem(icon_segment_point)
                                // console.log(routeModel.get(0).segments[segmentcounter].maneuver.instructionText) // for guidanceModule debug
                                // guidanceModule.guidance(routeModel.get(0).segments[segmentcounter].maneuver.instructionText)
                            }
                        }else{
                            if(next_cross_distance <= 330 && last_segmentcounter != segmentcounter) {
                                last_segmentcounter = segmentcounter
//                                console.log(routeModel.get(0).segments[segmentcounter].maneuver.instructionText) // for guidanceModule debug
                                guidanceModule.guidance(routeModel.get(0).segments[segmentcounter].maneuver.instructionText)
                            }
                            // update progress_next_cross
                            progress_next_cross.setProgress(next_cross_distance)
                        }
                    }
                }
            }
		}

        function removePoiIconsSLOT(category_id){
            console.log("called removePoiIcons")
            while(poiArray.length>0)
                map.removeMapItem(poiArray.pop())
        }

        function doGetRouteInfoSlot(){
            if(btn_guidance.sts_guide == 0){ // idle
                console.log("called doGetRouteInfoSlot sts_guide == idle")
                map.qmlSignalPosInfo(car_position_lat, car_position_lon,car_direction,car_accumulated_distance);
            }else if(btn_guidance.sts_guide == 1){ // Routing
                console.log("called doGetRouteInfoSlot sts_guide == Routing")
                map.qmlSignalPosInfo(car_position_lat, car_position_lon,car_direction,car_accumulated_distance);
                map.qmlSignalRouteInfo(car_position_lat, car_position_lon,routeQuery.waypoints[1].latitude,routeQuery.waypoints[1].longitude);
            }else if(btn_guidance.sts_guide == 2){ // onGuide
                console.log("called doGetRouteInfoSlot sts_guide == onGuide")
                map.qmlSignalRouteInfo(car_position_lat, car_position_lon,routeQuery.waypoints[1].latitude,routeQuery.waypoints[1].longitude);
            }
        }

        function rotateMapSmooth(){
            if(root.st_heading_up){
                map.state = "none"
                map.state = "smooth_rotate"
            }else{
                map.state = "smooth_rotate_north"
            }
        }

        function stopMapRotation(){
            map.state = "none"
            rot_anim.stop()
        }

        states: [
            State {
                name: "none"
            },
            State {
                name: "smooth_rotate"
                PropertyChanges { target: map; bearing: root.car_direction }
            },
            State {
                name: "smooth_rotate_north"
                PropertyChanges { target: map; bearing: 0 }
            }
        ]

        transitions: Transition {
            NumberAnimation { properties: "center"; easing.type: Easing.InOutQuad }
            RotationAnimation {
                id: rot_anim
                property: "bearing"
                direction: RotationAnimation.Shortest
                easing.type: Easing.InOutQuad
                duration: 200
            }
        }
    }
		
    BtnPresentPosition {
        id: btn_present_position
        anchors.right: parent.right
        anchors.rightMargin: 125
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 125
    }

	BtnMapDirection {
        id: btn_map_direction
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: 25
	}

    BtnGuidance {
        id: btn_guidance
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.right: parent.right
        anchors.rightMargin: 125
	}

	BtnShrink {
        id: btn_shrink
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 250
	}

	BtnEnlarge {
        id: btn_enlarge
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 125
	}

	ImgDestinationDirection {
        id: img_destination_direction
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: 150
	}

    ProgressNextCross {
        id: progress_next_cross
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.left: img_destination_direction.right
        anchors.leftMargin: 20
	}
}
