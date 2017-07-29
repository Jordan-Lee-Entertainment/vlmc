import QtQuick 2.0

ListView {
    id: container
    width: parent.width
    height: tracks.count * trackHeight
    verticalLayoutDirection: isUpward ? ListView.BottomToTop  : ListView.TopToBottom
    interactive: false
    focus: true
    model: tracks
    delegate: Track {
        trackId: index
        type: container.type
        clips: model["clips"]
    }

    property bool isUpward
    property string type
    property ListModel tracks
}

