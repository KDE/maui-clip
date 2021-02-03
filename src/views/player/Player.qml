import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import QtMultimedia 5.8
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

Maui.Page
{
    id: control
    property alias video : player
    property alias url : player.source

    readonly property bool playing : player.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : player.playbackState === MediaPlayer.PausedState
    readonly property bool stopped : player.playbackState === MediaPlayer.StoppedState

    headBar.visible: false
    floatingFooter: player.visible && !_playlist.visible
    autoHideFooter: floatingFooter

    autoHideFooterMargins: control.height

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"
    //    Connections
    //    {
    //        target: _appViews
    //        function onCurrentIndexChanged()
    //        {
    //            if(_appViews.currentIndex !== views.player && control.playing)
    //            {
    //                player.pause()
    //            }else
    //            {
    //                player.play()
    //            }
    //        }
    //    }

    Video
    {
        id: player
        visible: !control.stopped
        anchors.fill: parent
        autoLoad: true
        autoPlay: true
        focus: true
        Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
        Keys.onLeftPressed: player.seek(player.position - 5000)
        Keys.onRightPressed: player.seek(player.position + 5000)

        RowLayout
        {
            anchors.fill: parent

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position - 5000)
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position + 5000)
            }
        }
    }

    footBar.visible: true

    footer: Maui.TagsBar
        {
            id: tagBar
            visible: root.visibility !== Window.FullScreen
            position: ToolBar.Footer
            width: parent.width
            allowEditMode: true
            onTagsEdited:
            {
                tagBar.list.updateToUrls(tags)
            }

            list.strict: true
            list.urls:  [control.url]
        }


}
