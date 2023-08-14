import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtMultimedia 5.8

import org.mauikit.controls 1.3 as Maui

import mpv 1.0

MpvObject
{
    id: control
    property alias url : control.source
    property alias video : control

    readonly property bool playing : control.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : control.playbackState === MediaPlayer.PausedState
    readonly property bool stopped :  control.playbackState === MediaPlayer.StoppedState

    autoPlay: true
    hardwareDecoding: settings.hardwareDecoding
    onEndOfFile: playNext()


    Maui.InfoDialog
    {
        id: _subtitlesDialog
        title: i18n("Subtitles")

        Repeater
        {
            model: control.subtitleTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

    Maui.InfoDialog
    {
        id: _audioTracksDialog
        title: i18n("Audio Tracks")

        Repeater
        {
            model: control.audioTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

}




