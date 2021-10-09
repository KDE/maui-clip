import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtMultimedia 5.8

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

Video
{
    id: control
    property alias video : control
    property alias url : control.source

    readonly property bool playing : control.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : control.playbackState === MediaPlayer.PausedState
    readonly property bool stopped : control.playbackState === MediaPlayer.StoppedState

    source: currentVideo.url
    autoPlay: true
}

