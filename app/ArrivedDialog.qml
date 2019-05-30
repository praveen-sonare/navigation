import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

Rectangle {
    id: mainform
    height: 300
    width: 1080
    radius:2

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#12262E" }
        GradientStop { position: 1.0; color: "#18899B" }
    }

    ColumnLayout {
        anchors {
          topMargin: 10; bottomMargin:10
          leftMargin: 20; rightMargin: 20
          fill: parent
        }
        spacing: 2

        ColumnLayout {
            id: title_part
            anchors {
                top: parent.top
                left: parent.left
                    topMargin: 10
            }

            Label {
                id: title
                text: "Arrived Destination"
                color: "white"
                font.pixelSize: 32
                font.bold: true
                maximumLineCount: 1
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth:  960
                Layout.preferredHeight:  40
            }

            Image {
                source: '../images/DividingLine.svg'
                anchors.left: title.left
                anchors.top: title.bottom
            }
        }

        RowLayout {
            id: contents_part
            anchors {
              left: parent.left; leftMargin: 20
              right: parent.right; rightMargin: 20
            }
            Layout.preferredWidth: 920
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            spacing: 10
            Image {
                id: dsp_mark
                source: dsp_icon
                Layout.maximumHeight: 120
                Layout.maximumWidth:  120
            }
            Label {
                x: 60
                text: "You have arrived the destination.\n\n Guidance have stopped"
                color: "white"
                font.pixelSize: 24
                wrapMode: Text.Wrap
                maximumLineCount: btn_area.visible ? 4 : 5
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.preferredWidth: 780
                Layout.preferredHeight: 160
            }
        }


    }

}
