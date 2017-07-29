import QtQuick 2.0

Item {
    id: track
    width: parent.width
    height: trackHeight
    z: 10

    property int trackId
    property string type
    property ListModel clips

    Rectangle {
        id: clipArea
        x: trackInfo.width
        color: "#222222"
        height: parent.height
        width: track.width - initPosOfCursor

        Rectangle {
            color: "#666666"
            height: 1
            width: parent.width
            anchors.bottom: clipArea.bottom

            Component.onCompleted: {
                if ( track.type === "Video" && track.trackId == 0 )
                {
                    color = "#111111";
                }
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent
            keys: ["Clip", "vlmc/uuid"]

            // Enum for drop mode
            readonly property var dropMode: {
                "New": 0,
                "Move": 1,
            }

            property string currentUuid
            property var aClipInfo: null
            property var vClipInfo: null

            property int lastPos: 0
            property int deltaPos: 0

            onDropped: {
                if ( drop.keys.indexOf( "vlmc/uuid" ) >= 0 ) {
                    aClipInfo = findClipFromTrack( "Audio", trackId, "audioUuid" );
                    vClipInfo = findClipFromTrack( "Video", trackId, "videoUuid" );
                    var pos = 0;
                    if ( aClipInfo ) {
                        pos = aClipInfo["position"];
                        removeClipFromTrack( "Audio", trackId, "audioUuid" );
                    }
                    if ( vClipInfo ) {
                        pos = vClipInfo["position"];
                        removeClipFromTrack( "Video", trackId, "videoUuid" );
                    }
                    workflow.addClip( drop.getDataAsString("vlmc/uuid"), trackId, pos, false );
                    currentUuid = "";
                    aClipInfo = null;
                    vClipInfo = null;
                    clearSelectedClips();
                    adjustTracks( "Audio" );
                    adjustTracks( "Video" );
                }
            }

            onExited: {
                if ( currentUuid !== "" ) {
                    removeClipFromTrack( "Audio", trackId, "audioUuid" );
                    removeClipFromTrack( "Video", trackId, "videoUuid" );
                }
            }

            onEntered: {
                if ( drag.keys.indexOf( "vlmc/uuid" ) >= 0 ) {
                    clearSelectedClips();
                    if ( currentUuid === drag.getDataAsString( "vlmc/uuid" ) ) {
                        if ( aClipInfo )
                        {
                            aClipInfo["position"] = ptof( drag.x );
                            aClipInfo = addClip( "Audio", trackId, aClipInfo );
                        }
                        if ( vClipInfo )
                        {
                            vClipInfo["position"] = ptof( drag.x );
                            vClipInfo = addClip( "Video", trackId, vClipInfo );
                        }
                    }
                    else {
                        var newClipInfo = workflow.libraryClipInfo( drag.getDataAsString( "vlmc/uuid" ) );
                        currentUuid = "" + newClipInfo["uuid"];
                        newClipInfo["position"] = ptof( drag.x );
                        if ( newClipInfo["audio"] ) {
                            newClipInfo["uuid"] = "audioUuid";
                            aClipInfo = addClip( "Audio", trackId, newClipInfo );
                        }
                        if ( newClipInfo["video"] ) {
                            newClipInfo["uuid"] = "videoUuid";
                            vClipInfo = addClip( "Video", trackId, newClipInfo );
                        }
                    }
                    lastPos = ptof( drag.x );
                }
                else {
                    lastPos = ptof( drag.source.x );
                    // HACK: Call onPositoinChanged forcely here.
                    // x will be rounded so it won't affect actual its position.
                    drag.source.x = drag.source.x + 0.000001;
                }
            }

            onPositionChanged: {
                // If resizing, ignore
                if ( drag.source.resizing === true )
                    return;

                if ( drag.keys.indexOf( "vlmc/uuid" ) >= 0 )
                    var dMode = dropMode.New;
                else
                    dMode = dropMode.Move;

                sortSelectedClips();
                var toMove = selectedClips.concat();

                if ( dMode === dropMode.Move ) {
                    // Move to the top
                    drag.source.parent.parent.z = ++maxZ;

                    // Prepare newTrackId for all the selected clips
                    var oldTrackId = drag.source.newTrackId;
                    drag.source.newTrackId = trackId;

                    // Check if there is any impossible move
                    for ( var i = 0; i < toMove.length; ++i ) {
                        var target = findClipItem( toMove[i] );
                        if ( target !== drag.source ) {
                            var newTrackId = trackId - oldTrackId + target.trackId;
                            if ( newTrackId < 0 )
                            {
                                drag.source.newTrackId = oldTrackId;
                                drag.source.setPixelPosition( drag.source.pixelPosition() );

                                // Direction depends on its type
                                drag.source.y +=
                                        drag.source.type === "Video"
                                        ? -( trackHeight * ( oldTrackId - trackId ) )
                                        : trackHeight * ( oldTrackId - trackId )
                                return;
                            }
                        }
                    }

                    for ( i = 0; i < toMove.length; ++i ) {
                        target = findClipItem( toMove[i] );
                        if ( target !== drag.source ) {
                             newTrackId = trackId - oldTrackId + target.trackId;
                            target.newTrackId = Math.max( 0, newTrackId );
                            if ( target.newTrackId !== target.trackId ) {
                                // Let's move to the new tracks
                                target.clipInfo["selected"] = true;
                                addClip( target.type, target.newTrackId, target.clipInfo );
                                removeClipFromTrack( target.type, target.trackId, target.uuid );
                            }
                        }
                    }

                    deltaPos = ptof( drag.source.x ) - lastPos;
                }
                else
                    deltaPos = ptof( drag.x ) - lastPos;

                while ( toMove.length > 0 ) {
                    target = findClipItem( toMove[0] );
                    var oldPos = target.position;
                    var newPos = findNewPosition( Math.max( oldPos + deltaPos, 0 ), target, drag.source, isMagneticMode );
                    deltaPos = newPos - oldPos;

                    // Let's find newX of the linked clip
                    for ( i = 0; i < target.linkedClips.length; ++i )
                    {
                        var linkedClipItem = findClipItem( target.linkedClips[i] );

                        if ( linkedClipItem ) {
                            var newLinkedClipPos = findNewPosition( newPos, linkedClipItem, drag.source, isMagneticMode );

                            // If linked clip collides
                            if ( newLinkedClipPos !== newPos ) {
                                // Recalculate target's newX
                                // This time, don't use magnets
                                if ( isMagneticMode === true )
                                {
                                    newLinkedClipPos = findNewPosition( newPos, linkedClipItem, drag.source, false );
                                    newPos = findNewPosition( newPos, target, drag.source, false );

                                    // And if newX collides again, we don't move
                                    if ( newLinkedClipPos !== newPos )
                                        deltaPos = 0
                                    else
                                        deltaPos = newPos - oldPos;
                                }
                                else
                                    deltaPos = 0;
                            }
                            else
                                deltaPos = newPos - oldPos;

                            var ind = toMove.indexOf( linkedClipItem.uuid );
                            if ( ind > 0 )
                                toMove.splice( ind, 1 );
                        }
                    }

                    newPos = oldPos + deltaPos;
                    toMove.splice( 0, 1 );
                }
                // END of while ( toMove.length > 0 )

                if ( deltaPos === 0 && dMode === dropMode.Move ) {
                    drag.source.forcePosition(); // Use the original position
                    return;
                }

                for ( i = 0; i < selectedClips.length; ++i ) {
                    target = findClipItem( selectedClips[i] );
                    newPos = target.position + deltaPos;

                    // We only want to update the length when the left edge of the timeline
                    // is exposed.
                    if ( sView.flickableItem.contentX + page.width > sView.width &&
                            length < newPos + target.length ) {
                        length = newPos + target.length;
                    }

                    target.position = newPos;

                    // Scroll if needed
                    if ( drag.source === target || dMode === dropMode.New )
                        target.scrollToThis();
                }

                if ( dMode === dropMode.Move )
                    lastPos = ptof( drag.source.x );
                else
                    lastPos = ptof( drag.x );
            }
        }

        Repeater {
            id: repeater
            model: clips
            delegate: Clip {
                height: track.height - 3
                name: model.name
                trackId: model.trackId
                type: track.type
                uuid: model.uuid
                libraryUuid: model.libraryUuid
                position: model.position
                lastPosition: model.position
                begin: model.begin
                end: model.end
                length: model.length
                clipInfo: model
            }
        }
    }

    Rectangle {
        id: trackInfo
        x: sView.flickableItem.contentX
        width: initPosOfCursor
        height: parent.height
        color: "#444444"

        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "#111111"
        }

        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: "#111111"
        }

        Rectangle {
            width: 1
            height: parent.height
            anchors.right: parent.right
            color: "#111111"
        }

        Text {
            id: trackText
            anchors.verticalCenter: parent.verticalCenter
            x: 10
            text: type + " " + ( trackId + 1 )
            color: "white"
            font.pointSize: 10
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: trackText.y + trackText.contentWidth + 10
            spacing: 4

            PropertyButton {
                id: fxButton
                text: "Fx"
                selected: true

                onSelectedChanged: {
                    if ( selected === false ) {
                        workflow.showEffectStack( trackId );
                        selected = true;
                    }
                }
            }
        }
    }
}

