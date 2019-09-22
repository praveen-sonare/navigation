/*
 * Copyright (C) 2016 The Qt Company Ltd.
 * Copyright (C) 2017 Konsulko Group
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtPositioning 5.5
import QtWebSockets 1.0

WebSocket {
    id: root
    active: true
    url: bindingAddress

    property string statusString: "waiting..."
    property string apiString: "geofence"
    property string payloadLength: "9999"

    property bool loop_state: false
    property bool running: false

    readonly property var msgid: {
        "call": 2,
        "retok": 3,
        "reterr": 4,
        "event": 5
    }

    onTextMessageReceived: {
        var json = JSON.parse(message)
        console.debug("Raw response: " + message)
        var request = json[2].request
        var response = json[2].response
        console.debug("response: " + JSON.stringify(response))
        switch (json[0]) {
            case msgid.call:
                break
            case msgid.retok:
                break
            case msgid.reterr:
                root.statusString = "Bad return value, binding probably not installed"
                break
            case msgid.event:
                var payload = JSON.parse(JSON.stringify(json[2]))
                var event = payload.event
                if (event === "geofence/fence") {
                    var data = json[2].data
                    console.log("geofence event - name: " + data.name + " state: " + data.state)
                }
                break
        }
    }

    onStatusChanged: {
        switch (status) {
            case WebSocket.Open:
            console.debug("onStatusChanged: Open")
            //sendSocketMessage("add_fence", { name: "Stop Sign",
            //            bbox: { min_longitude: -122.499217, max_longitude: -122.498732,
            //                    min_latitude: 45.600136, max_latitude: 45.600384 }
            //            })
            sendSocketMessage("subscribe", { value: "fence" })
            break
            case WebSocket.Error:
            root.statusString = "WebSocket error: " + root.errorString
            break
        }
    }

    function sendSocketMessage(verb, parameter) {
        var requestJson = [ msgid.call, payloadLength, apiString + '/'
        + verb, parameter ]
        console.debug("sendSocketMessage: " + JSON.stringify(requestJson))
        sendTextMessage(JSON.stringify(requestJson))
    }
}
