import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import QtMultimedia 5.8
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

import mpv 1.0

Maui.Page
{
    id: control
    property alias video : _mpv
    property alias url : _mpv.url

    readonly property bool playing : !_mpv.pause
    readonly property bool paused : _mpv.pause
    readonly property bool stopped : true

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


    MpvObject
    {
        id: _mpv
        anchors.fill: parent
         autoPlay: true
    }


//    Video
//    {
//        id: player
//        visible: !control.stopped
//        anchors.fill: parent
//        autoLoad: true
//        autoPlay: true
//        focus: true
//        Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
//        Keys.onLeftPressed: player.seek(player.position - 5000)
//        Keys.onRightPressed: player.seek(player.position + 5000)

//        RowLayout
//        {
//            anchors.fill: parent

//            MouseArea
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                onDoubleClicked: player.seek(player.position - 5000)
//            }

//            MouseArea
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
//            }

//            MouseArea
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                onDoubleClicked: player.seek(player.position + 5000)
//            }
//        }
//    }

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
