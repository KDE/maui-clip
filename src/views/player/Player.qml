import QtMultimedia
import QtQuick

Video
{
    id: control
    readonly property alias video : control
    property alias url : control.source

    readonly property bool playing : control.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : control.playbackState === MediaPlayer.PausedState
    readonly property bool stopped : control.playbackState === MediaPlayer.StoppedState

    source: currentVideo.url
    autoPlay: true
    // autoLoad: true
    fillMode: VideoOutput.PreserveAspectFit
    // flushMode: VideoOutput.LastFrame
    // audioRole: MediaPlayer.VideoRole
}

