import QtQuick 2.0
import QtQuick.Controls 1.5

Item {
	Button {
		width: 100
		height: 100

        function zoomUp() {
            map.zoomLevel += 1
		}

        onClicked: { zoomUp() }

		Image {
			id: image
			width: 92
			height: 92
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
            source: "images/240px-Antu_kdenlive-zoom-large.svg.png"
		}
	}
}
