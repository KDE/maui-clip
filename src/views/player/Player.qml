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
    property alias url : _mpv.source

    readonly property bool playing : _mpv.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : _mpv.playbackState === MediaPlayer.PausedState
    readonly property bool stopped :  _mpv.playbackState === MediaPlayer.StoppedState

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

    Maui.Dialog
    {
        id: _subtitlesDialog
        title: i18n("Subtitles")

        Repeater
        {
            model: _mpv.subtitleTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

    Maui.Dialog
    {
        id: _audioTracksDialog
        title: i18n("Audio Tracks")

        Repeater
        {
            model: _mpv.audioTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

    MpvObject
    {
        id: _mpv
        anchors.fill: parent
        autoPlay: true
        hardwareDecoding: settings.hardwareDecoding
        onEndOfFile: playNext()

        BusyIndicator
        {
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
            Kirigami.Theme.inherit: false

            anchors.centerIn: parent
            running: _mpv.status === MediaPlayer.Loading
        }

        Label
        {
            color: "orange"
            text: _mpv.status +"/"+ MediaPlayer.NoMedia
        }

        Row
        {
            visible: !control.stopped
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Maui.Badge
            {
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Kirigami.Theme.inherit: false

                text: "CC"

                onClicked: _subtitlesDialog.open()

            }

            Maui.Badge
            {
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Kirigami.Theme.inherit: false

                text: "Audio"

                onClicked: _audioTracksDialog.open()

            }
        }
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
        visible: root.visibility !== Window.FullScreen && settings.playerTagBar
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
