import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtMultimedia

import org.mauikit.controls as Maui

import mpv 1.0

MpvObject
{
    id: control
    property alias url : control.source
    property alias video : control

    readonly property bool isPlaying : control.playbackState === MediaPlayer.PlayingState
    readonly property bool isPaused : control.playbackState === MediaPlayer.PausedState
    readonly property bool isStopped :  control.playbackState === MediaPlayer.StoppedState

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




