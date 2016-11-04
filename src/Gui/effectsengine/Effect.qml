import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3


Rectangle {
    id: effect
    color: "#444444"
    border.color: "#222222"
    border.width: 1

    width: parent.width
    height: childrenRect.height

    property string identifier
    property string name
    property string description

    Column {
        Text {
            text: name
            font.pointSize: 14
            color: "#EEEEEE"
            elide: Text.ElideRight
        }

        Text {
            text: description
            color: "#EEEEEE"
            elide: Text.ElideRight
        }
    }
    MouseArea {
        anchors.fill: parent
        onPressed: {
            view.startDrag( identifier );
        }
    }
}
