import QtQuick 2.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4

Item {
	id: progress_next_cross

    visible: false

    // val [Input]
    //   distance to next cross. (unit = meter)
    //   when over the ProgressBar.maximumValue/m, progress bar indicates max (same as ProgressBar.maximumValue/m)
    function setProgress(val) {
        if ( (0 < val) && (val < bar.maximumValue ) ) {
            bar.value = val
        }else if ( bar.maximumValue < val ){
            bar.value = bar.maximumValue
        }else{
            bar.value = 0
        }
	}

	ProgressBar {
		id: bar
		width: 25
		height: 100
        orientation: Qt.Vertical
        value: 0
        minimumValue: 0
        maximumValue: 300

        style: ProgressBarStyle {
            progress: Rectangle {
                color: "green"
            }
        }
	}
    states: [
        State {
            name: "visible"; PropertyChanges { target: progress_next_cross; visible: true }},
        State {
            name: "invisible"; PropertyChanges { target: progress_next_cross; visible: false }}
    ]

}
