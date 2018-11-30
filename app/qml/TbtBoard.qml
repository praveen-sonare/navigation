import QtQuick 2.0

//turn by turn board view
Item {
    id: tbt_board

    property bool showboard: false

    // the backgroud image(the small one)
    Image {
        id: whitebackgroud
        visible: !showboard
        anchors.top: parent.top
        width:turnDirection.width
        height:turnDirection.height + distance.height
        source: "qrc:simple-background-white.png"
        z: 1
    }

    // turn direction arrow board image(the small one)
    Image {
        id: turnDirection
        visible: !showboard
        anchors.top: parent.top
        z: 3
    }

    // the distance to the next crossing road(textview)(the small one)
    Text {
        id: distance
        visible: !showboard
        anchors.top: turnDirection.bottom
        z: 3
        font.pixelSize: 23
        width:turnDirection.width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Lato"
        font.weight: Font.Light
        color: "#000000"
    }

    // the backgroud image
    Image {
        id: backgroudBoard
        visible: showboard
        anchors.fill: parent
        source: "qrc:simple-bottom-background-black.png"
        z: 1
    }

    // turn direction arrow board image
    Image {
        id: turnDirectionBoard
        visible: showboard
        width : parent.height - turnInstructionsBoard.height - distanceBoard.height
        height: parent.height - turnInstructionsBoard.height - distanceBoard.height
        anchors.centerIn: parent
        z: 3
    }

    // the distance to the next crossing road(textview)
    Text {
        id: distanceBoard
        visible: showboard
        anchors.bottom: turnInstructionsBoard.top
        z: 3
        font.pixelSize: 45
        width:tbt_board.width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Lato"
        font.weight: Font.Light
        color: "#FFFFFF"
    }

    // the description of the next crossing road(textview)
    Text {
        id: turnInstructionsBoard
        visible: showboard
        anchors.bottom: parent.bottom
        z: 3
        font.pixelSize: 30
        width:tbt_board.width
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Lato"
        font.weight: Font.Light
        color: "#FFFFFF"
    }

    // the cases of direction arrow board
    states: [
        State {
            name: "arriveDest" //arrive the destination
            PropertyChanges { target: turnDirectionBoard; source: "qrc:destination_full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:destination.png" }
        },
        State {
            name: "0" // NoDirection
            PropertyChanges { target: turnDirectionBoard; source: "" }
            PropertyChanges { target: turnDirection; source: "" }
        },
        State {
            name: "1" // DirectionForward
            PropertyChanges { target: turnDirectionBoard; source: "" }
            PropertyChanges { target: turnDirection; source: "" }
        },
        State {
            name: "2" // DirectionBearRight
            PropertyChanges { target: turnDirectionBoard; source: "" }
            PropertyChanges { target: turnDirection; source: "" }
        },
        State {
            name: "3" // DirectionLightRight
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-r-30-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-r-30-large.png" }
        },
        State {
            name: "4" // DirectionRight
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-r-45-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-r-45-large.png" }
        },
        State {
            name: "5" // DirectionHardRight
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-r-75-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-r-75-large.png" }
        },
        State {
            name: "6" // DirectionUTurnRight
            //TODO modify qtlocation U-Turn best.For test, change app source.
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-l-180-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-l-180-large.png" }
        },
        State {
            name: "7" // DirectionUTurnLeft
            //TODO modify qtlocation U-Turn best.For test, change app source.
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-r-180-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-r-180-large.png" }
        },
        State {
            name: "8" // DirectionHardLeft
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-l-75-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-l-75-large.png" }
        },
        State {
            name: "9" // DirectionLeft
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-l-45-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-l-45-large.png" }
        },
        State {
            name: "10" // DirectionLightLeft
            PropertyChanges { target: turnDirectionBoard; source: "qrc:arrow-l-30-full.png" }
            PropertyChanges { target: turnDirection; source: "qrc:arrow-l-30-large.png" }
        },
        State {
            name: "11" // DirectionBearLeft
            PropertyChanges { target: turnDirectionBoard; source: "" }
            PropertyChanges { target: turnDirection; source: "" }
        }
    ]

    // Set distance
    function do_setDistance(dis) {
        if(dis > 1000)
        {
           distanceBoard.text = (dis / 1000).toFixed(1) + " km"
        }
        else
        {
           distanceBoard.text = dis + " m"
        }

        distance.text = (((dis/100).toFixed(0))*100) +"m"
    }

    //set turnInstructions
    function do_setTurnInstructions(turnInstructions) {
        turnInstructionsBoard.text = turnInstructions
    }

    //show the tbt board(the big one)
    function do_showTbtboard(mvisible) {
       showboard = mvisible
    }
}
