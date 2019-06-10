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
	title: qsTr("navigation")

    property real car_position_lat: fileOperation.getStartLatitude()
    property real car_position_lon: fileOperation.getStartLongitute()
    property real car_direction: 0  //North
    property real car_driving_speed: fileOperation.getCarSpeed()  // set Km/h
    property bool st_heading_up: false
    property real default_zoom_level : 18
    property real default_car_direction : 0
    property real car_accumulated_distance : 0
    property real positionTimer_interval : fileOperation.getUpdateInterval() // set millisecond
    property real car_moving_distance : (car_driving_speed / 3.6) / (1000/positionTimer_interval) // Metric unit
    property real last_car_pos_lat: fileOperation.getStartLatitude()
    property real last_car_pos_lon: fileOperation.getStartLongitute()
    property real car_driving_distance : 0


    property string navigation_request_str: ""
    property string api_str: "naviapi"
    property string verb_setcurretpos: "navicore_setcurrentpos"
    property string verb_getcurretpos: "navicore_getcurrentpos"
    property string verb_setallsessions: "navicore_setallsessions"
    property string verb_setallroutes: "navicore_setallroutes"
    property string verb_subscribe: "subscribe"
    property string verb_unsubscribe: "unsubscribe"
    property string verb_stopdemo: "navicore_stopdemo"
    property string verb_arrivedest: "navicore_arrivedest"
    property string verb_setdestpos: "navicore_setdestpos"
    property string verb_setdemorouteinfo: "navicore_setdemorouteinfo"
    property string verb_startguidance: "navicore_startguidance"
    property string verb_cancelguidance: "navicore_cancelguidance"
    property string verb_setdestinationdirection: "navicore_setdestdir"
    property string event_setwaypoints: "naviapi/navicore_setwaypoints"
    property string event_pausesimulation: "naviapi/navicore_pausesimulation"
    property string event_gps: "naviapi/navicore_gps"
    property string event_heading: "naviapi/navicore_heading"
    property var msgid_enu: { "call":2, "retok":3, "reterr":4, "event":5 }

    WebSocket {
        id: websocket
        url: bindingAddress

        onStatusChanged: {
            if (websocket.status === WebSocket.Error){
                console.log ("Error: " + websocket.errorString)
                websocket.active = false
                countdown.start()
            }else if (websocket.status === WebSocket.Open){
                console.log ("Socket Open")
                do_subscribe("gps")
                do_setallsessions()
                //do_setcurrentpos()
                do_getcurrentpos()
                do_setallroutes(0)
                do_subscribe("setwaypoints")
                do_subscribe("pausesimulation")
//                do_subscribe("gps")
//                do_subscribe("heading")
            }else if (websocket.status === WebSocket.Closed){
                console.log ("Socket closed")
            }
        }

        onTextMessageReceived: {
            var message_json = JSON.parse(message)
//            console.log("navi:onTextMessageReceived: " + message)
            if (message_json[0] === msgid_enu.event){
                //add destination from poi app
                if(message_json[2].event === event_setwaypoints){
                    var latitude = message_json[2].data[0].latitude
                    var longitude = message_json[2].data[0].longitude
                    var startFromCurrentPos = message_json[2].data[0].startFromCurrentPosition
//                    map.doSetWaypointsSlot(latitude,longitude,startFromCurrentPos);
                    map.initDestination()
                    map.center = map.currentpostion
                     map.addDestination(QtPositioning.coordinate(35.6585580781371,139.745503664017))
                    vui_startguidance()
                }
                //Pause Simulation from poi app
                else if(message_json[2].event === event_pausesimulation){
                    map.doPauseSimulationSlot()
                }
                else if(message_json[2].event === event_gps){
                    //console.log ("navi:Receive Event======event_gps")
                    var lat = message_json[2].data.latitude
                    var lon = message_json[2].data.longitude
                    //console.log ("navi:Receive Event lat====== " + lat+" "+"lon======"+lon)
                     map.currentpostion = QtPositioning.coordinate(lat, lon);
                    //console.log ("navi:last_car_pos_lat====== " + last_car_pos_lat+" "+"last_car_pos_lon======"+last_car_pos_lon)
                    car_driving_distance = map.calculateDistance(last_car_pos_lat,last_car_pos_lon,lat,lon)
                    //console.log("navi:car_driving_distance ====== "+car_driving_distance)
                    last_car_pos_lat = lat
                    last_car_pos_lon = lon

                    if(btn_guidance.sts_guide === 2){
                       map.updatePositon()

                    }

                }

            }
            else if(message_json[0] === msgid_enu.retok){
                if (message_json[2].request.info === verb_getcurretpos){
                    //console.log("navi:Callback Response ====== verb_getcurretpos")
                    var currentlat = message_json[2].response[0].CurrentLatitude
                    var currentlon = message_json[2].response[0].CurrentLongitude
//                    var currentheading = message_json[2].response[0].CurrentHeading
                     console.log ("navi:Response verb_getcurretpos currentlat====== " + currentlat+" currentlon======"+currentlon)
                    car_position_lat = currentlat
                    car_position_lon = currentlon
//                    car_direction = currentheading
                    last_car_pos_lat = currentlat
                    last_car_pos_lon = currentlon
                }
            }
        }
        active: false
    }

    Timer {
        id: countdown
        repeat: false
        interval: 3000
        triggeredOnStart: false
        onTriggered: {
            websocket.active = true
        }
    }

    onVisibleChanged: {
        if(visible){
            if (!websocket.active){
                websocket.active = true
            }
        }
        else{
            countdown.stop()
        }
    }

    Timer {
        id: dialogtimer
        repeat: false
        interval: 5000
        triggeredOnStart: false
        onTriggered: {
            arrived.visible = false
            btn_guidance.stopGuidance()
//            btn_guidance.sts_guide = 0
        }
    }

    //set all sessions
    function do_setallsessions() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setallsessions + '", {"sessionHandle":"' + 1 + '","client":"'+"dummy"+ '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //set current Position
    function do_setcurrentpos() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setcurretpos + '", {"latitude":"' + car_position_lat + '","longitude":"'+car_position_lon+ '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //get current Position
    function do_getcurrentpos() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_getcurretpos + '", {} ]'
        websocket.sendTextMessage (navigation_request_str)
//        console.log ("navi:get current Position====== " + navigation_request_str)
    }

    //set all routes(current route count)
    function do_setallroutes( route ) {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setallroutes + '", {"route":"' + route + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //subscribe
    function do_subscribe( event ) {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_subscribe + '", {"value":"' + event + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
//        console.log ("navi:subscribe====== " + navigation_request_str)
    }

    //stop demo
    function do_stopdemo() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_stopdemo + '", {"stopdemo":"' + true + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //arrive the destnition
    function do_arrivedest() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_arrivedest + '", {"arrivedest":"' + true + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //set the route infomation during the demo
    function do_setdemorouteinfo(latitude,longitude,direction,distance) {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setdemorouteinfo + '", {"DemoLatitude":"' + latitude+ '","DemoLongitude":"'+longitude + '","DemoDistance":"'+distance+ '","DemoDirection":"'+direction+ '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

//    //set the route infomation during the demo
//    function do_setdemorouteinfo(direction,distance) {
//        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setdemorouteinfo + '", {"DemoDistance":"'+distance+ '","DemoDirection":"'+direction+ '"} ]'
//        websocket.sendTextMessage (navigation_request_str)
//    }

    //setting the destinition
    function do_setdestpos(latitude,longitude) {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setdestpos + '", {"DestLatitude":"' + latitude+ '","DestLongitude":"'+longitude + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
    }

    //start guidance
    function do_startguidance() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_startguidance + '", {"startguidance":"' + true + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
        console.log("navi:do_startguidance = " + navigation_request_str)
    }

    //cancel guidance
    function do_cancelguidance() {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_cancelguidance + '", {"cancelguidance":"' + true + '"} ]'
        websocket.sendTextMessage (navigation_request_str)
        console.log("navi:do_cancelguidance = " + navigation_request_str)
    }

    //set the destination direction during the demo
    function do_setdestinationdirection(direction) {
        navigation_request_str = '[' + msgid_enu.call + ',"99999","' + api_str+'/'+verb_setdestinationdirection + '", {"state":"'+direction+ '"} ]'
        websocket.sendTextMessage (navigation_request_str)
        console.log("navi:do_setdestinationdirection = " + navigation_request_str)
    }


    function vui_startguidance(){
        btn_guidance.startGuidance()
        console.log("vui_startguidance started")
    }
    function vui_cancelguidance(){
        btn_guidance.discardWaypoints()
        console.log("vui_cancelguidance started")
    }

    Map{
		id: map
        property int pathcounter : 0
        property int segmentcounter : 0
        property int waypoint_count: -1
		property int lastX : -1
		property int lastY : -1
		property int pressX : -1
		property int pressY : -1
		property int jitterThreshold : 30
        property variant currentpostion : QtPositioning.coordinate(car_position_lat, car_position_lon)
        property int last_segmentcounter : -1

        signal qmlSignalRouteInfo(double srt_lat,double srt_lon,double end_lat,double end_lon);
        signal qmlSignalPosInfo(double lat,double lon,double drc,double dst);
        signal qmlSignalStopDemo();
        signal qmlSignalArrvied();
        signal qmlCheckDirection(double cur_dir,double next_dir,double is_rot);

        width: parent.width
        height: parent.height
        plugin: Plugin {
            name: "mapboxgl"
            PluginParameter { name: "mapboxgl.access_token";
            value: fileOperation.getMapAccessToken() }
            PluginParameter { name: "mapboxgl.mapping.additional_style_urls";
            value: fileOperation.getMapStyleUrls() }
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
                width: 48
                height: 48
                source: "images/position02.svg"

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
                source: "images/HEB_project_flow_icon_04_checkered_flag.svg"
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
            id:icon_segment_point
            anchorPoint.x: _image.width/2 - 5
            anchorPoint.y: _image.height/2 + 25
            sourceItem: Image {
                id: _image
                width: 64
                height: 64
                source: "images/Map_symbol_location_02.png"
            }
        }

		RouteModel {
			id: routeModel
            objectName: "routeModel"
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
						map.segmentcounter = 0
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

        function addStartPoint(){
            icon_start_point.coordinate = currentpostion
            map.addMapItem(icon_start_point)
        }

        function addDestination(coord){
            console.log("navi:dest coord.latitude ============" + coord.latitude +" dest coord.longitude"+coord.longitude)
            if( waypoint_count < 0 ){
                initDestination()
            }

            if(waypoint_count == 0)  {
                // set icon_start_point
//                icon_start_point.coordinate = currentpostion
//                map.addMapItem(icon_start_point)
            }

            if(waypoint_count < 9){
                routeQuery.addWaypoint(coord)
                waypoint_count += 1
                do_setallroutes(waypoint_count)
                btn_guidance.sts_guide = 1
                btn_guidance.state = "Routing"

                var waypointlist = routeQuery.waypoints
                for(var i=1; i<waypoint_count; i++) {
                    markerModel.addMarker(waypointlist[i])
                }

                routeModel.update()
                map.qmlSignalRouteInfo(car_position_lat, car_position_lon,coord.latitude,coord.longitude)

                // update icon_end_point
                icon_end_point.coordinate = coord
                do_setdestpos(coord.latitude,coord.longitude)
                map.addMapItem(icon_end_point)
            }
        }

        function resetDestination(){

            routeModel.reset();
            console.log("navi:resetWaypoint")

            // reset currentpostion
            car_accumulated_distance = 0
            do_setdemorouteinfo(car_direction,car_accumulated_distance)

            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(map.currentpostion)
            routeQuery.travelModes = RouteQuery.CarTravel
            routeQuery.routeOptimizations = RouteQuery.FastestRoute
            for (var i=0; i<9; i++) {
                routeQuery.setFeatureWeight(i, 0)
            }
            waypoint_count = 0
            pathcounter = 0
            segmentcounter = 0
            routeModel.update();
            markerModel.removeMarker();
            map.removeMapItem(markerModel);

            do_setallroutes(waypoint_count)
            do_setdestpos("","")

            // remove MapItem
            map.removeMapItem(icon_start_point)
            map.removeMapItem(icon_end_point)
            map.removeMapItem(icon_segment_point)

            // update car_position_mapitem angle
//            root.car_direction = root.default_car_direction

        }

        function initDestination(startFromCurrentPosition){
            if (startFromCurrentPosition === undefined) startFromCurrentPosition = false
            routeModel.reset();
            console.log("initWaypoint")

            // reset currentpostion
            map.currentpostion = QtPositioning.coordinate(car_position_lat, car_position_lon)
            car_accumulated_distance = 0
            do_setdemorouteinfo(car_position_lat, car_position_lon,car_direction,car_accumulated_distance)
//            do_setdemorouteinfo(car_direction,car_accumulated_distance)


            routeQuery.clearWaypoints();
            routeQuery.addWaypoint(map.currentpostion)
            routeQuery.travelModes = RouteQuery.CarTravel
            routeQuery.routeOptimizations = RouteQuery.FastestRoute
            for (var i=0; i<9; i++) {
                routeQuery.setFeatureWeight(i, 0)
            }
            waypoint_count = 0
            pathcounter = 0
            segmentcounter = 0
            routeModel.update();
            markerModel.removeMarker();
            map.removeMapItem(markerModel);

            do_setallroutes(waypoint_count)
            do_setdestpos("","")

            // remove MapItem
            map.removeMapItem(icon_start_point)
            map.removeMapItem(icon_end_point)
            map.removeMapItem(icon_segment_point)

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
//                        map.addDestination(lastCoordinate)
                        map.initDestination()
                        map.center = map.currentpostion
                        map.addDestination(QtPositioning.coordinate(35.6585580781371,139.745503664017))
//                        root.vui_startguidance()
//                        btn_guidance.sts_guide = 2;
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
            //console.log("navi: pathcounter = "+pathcounter+" path.length = "+routeModel.get(0).path.length)
            //console.log("navi: segmentcounter = "+segmentcounter+" segments.length = "+routeModel.get(0).segments.length)
            if(pathcounter <= routeModel.get(0).path.length - 1){
                // calculate distance
                var next_distance = calculateDistance(map.currentpostion.latitude,
                                                      map.currentpostion.longitude,
                                                      routeModel.get(0).path[pathcounter].latitude,
                                                      routeModel.get(0).path[pathcounter].longitude);


                // calculate direction
                var next_direction = calculateDirection(map.currentpostion.latitude,
                                                        map.currentpostion.longitude,
                                                        routeModel.get(0).path[pathcounter].latitude,
                                                        routeModel.get(0).path[pathcounter].longitude);

                // calculate next cross distance
                var next_cross_distance = calculateDistance(map.currentpostion.latitude,
                                                            map.currentpostion.longitude,
                                                            routeModel.get(0).segments[segmentcounter].path[0].latitude,
                                                            routeModel.get(0).segments[segmentcounter].path[0].longitude);

                //console.log("navi:next_distance="+next_distance+" next_direction"+next_direction+" next_cross_distance"+next_cross_distance)

                // map rotateAnimation cntrol
                if(root.st_heading_up) {
                    var is_rotating = 0;
                    var cur_direction = Math.floor(map.bearing);

                    // check is_rorating
                    if(cur_direction > Math.floor(next_direction)){
                        is_rotating = Math.floor(cur_direction - next_direction);
                    }else{
                        is_rotating = Math.floor(next_direction - cur_direction);
                    }

                    if(is_rotating > 180){
                        is_rotating = 360 - is_rotating;
                    }

                    //console.log("navi:is_rotating========= "+ is_rotating)

                    // rotation angle case
                    if(is_rotating > 180){
                        // driving stop hard turn
                        root.car_moving_distance = 0;
                        rot_anim.duration = 1600;
                        rot_anim.easing.type = Easing.OutQuint;
                    } else if(is_rotating > 90){
                        // driving stop normal turn
                        root.car_moving_distance = 0;
                        rot_anim.duration = 800;
                        rot_anim.easing.type = Easing.OutQuart;
                    } else if(is_rotating > 60){
                        // driving slow speed normal turn
                        root.car_moving_distance = ((car_driving_speed / 3.6) / (1000/positionTimer_interval)) * 0.3;
                        rot_anim.duration = 400;
                        rot_anim.easing.type = Easing.OutCubic;
                    } else if(is_rotating > 30){
                        // driving half speed soft turn
                        root.car_moving_distance = ((car_driving_speed / 3.6) / (1000/positionTimer_interval)) * 0.5;
                        rot_anim.duration = 300;
                        rot_anim.easing.type = Easing.OutQuad;
                    } else {
                        // driving nomal speed soft turn
                        root.car_moving_distance = (car_driving_speed / 3.6) / (1000/positionTimer_interval);
                        rot_anim.duration = 200;
                        rot_anim.easing.type = Easing.OutQuad;
                    }
                }else{
                    // NorthUp
                    root.car_moving_distance = (car_driving_speed / 3.6) / (1000/positionTimer_interval);
                    rot_anim.duration = 200;
                    rot_anim.easing.type = Easing.OutQuad;
                }

                root.car_direction = next_direction;

                // set next coordidnate
                if(next_distance < 3)
                {
//                    car_accumulated_distance += next_distance
//                    do_setdemorouteinfo(map.currentpostion.latitude, map.currentpostion.longitude,next_direction,car_accumulated_distance)
                    //("lqy:pathcounter ======" + pathcounter)
//                    console.log("lqy:routeModel.get(0).path.length - 1 ======" + routeModel.get(0).path.length - 1)
                    if(pathcounter < routeModel.get(0).path.length - 1){
                        pathcounter++
                    }
                    else
                    {
                        // Arrive at your destination
                        btn_guidance.sts_guide = 0
                        do_arrivedest()
//                        msg_dialog.open()
                        arrived.visible = true
                        dialogtimer.start()
                    }
                }else{
                    if(pathcounter != 0){
//                        car_accumulated_distance += root.car_moving_distance
                    }
//                   do_setdemorouteinfo(map.currentpostion.latitude, map.currentpostion.longitude,next_direction,car_accumulated_distance)
                }

                //console.log("navi:car_accumulated_distance======" + car_accumulated_distance)
                car_accumulated_distance += car_driving_distance
                do_setdemorouteinfo(map.currentpostion.latitude,map.currentpostion.longitude,next_direction,next_cross_distance)

                if(btn_present_position.state === "Flowing")
                {
                    // update map.center
                    map.center = map.currentpostion
                }
                rotateMapSmooth()

                // report a new instruction if current position matches with the head position of the segment
                if(segmentcounter <= routeModel.get(0).segments.length - 1){
                     if(next_cross_distance < 2){
                        progress_next_cross.setProgress(0)
                        if(segmentcounter < routeModel.get(0).segments.length - 1){
                            segmentcounter++
                        }
                        if(segmentcounter === routeModel.get(0).segments.length - 1){
                            img_destination_direction.state = "12"
                            map.removeMapItem(icon_segment_point)
                            root.do_setdestinationdirection(img_destination_direction.state)
                        }else{
                            img_destination_direction.state = routeModel.get(0).segments[segmentcounter].maneuver.direction
                            icon_segment_point.coordinate = routeModel.get(0).segments[segmentcounter].path[0]
                            map.addMapItem(icon_segment_point)
                            root.do_setdestinationdirection(img_destination_direction.state)
                        }
                    }else{
                        if(next_cross_distance <= 330 && last_segmentcounter != segmentcounter) {
                            last_segmentcounter = segmentcounter
                            guidanceModule.guidance(routeModel.get(0).segments[segmentcounter].maneuver.instructionText)
                        }
                        // update progress_next_cross
                        progress_next_cross.setProgress(next_cross_distance)
                    }
                }
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

        function doPauseSimulationSlot(){
            btn_guidance.discardWaypoints();
        }

        function doGetAllRoutesSlot(){
            return routeModel.count;
        }

        function doSetWaypointsSlot(latitude,longitue,startFromCurrentPosition){

            if(btn_guidance.state !== "idle")
                btn_guidance.discardWaypoints(startFromCurrentPosition);

            if(btn_present_position.state === "Optional"){
                map.center = map.currentpostion
                btn_present_position.state = "Flowing"
            }

            if((btn_guidance.state !== "onGuide") && (btn_guidance.state !== "Routing"))
                map.addDestination(QtPositioning.coordinate(latitude,longitue))
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
                easing.type: Easing.OutQuad
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
        function setGuidanceState(){
            btn_guidance.stopGuidance()
        }
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


    ArrivedDesDialog {
        id:arrived
        x:40
        y:594
        visible: false
    }
}
