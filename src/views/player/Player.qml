import QtMultimedia
import QtQuick

Video
{
    id: control
    readonly property alias video : control
    property alias url : control.source

    readonly property bool isPlaying : control.playbackState === MediaPlayer.PlayingState
    readonly property bool isPaused : control.playbackState === MediaPlayer.PausedState
    readonly property bool isStopped : control.playbackState === MediaPlayer.StoppedState

    // source: currentVideo.url ? currentVideo.url  : undefined
    autoPlay: true
    // seekable: true
    loops: 2
    // focus: true
    endOfStreamPolicy: VideoOutput.KeepLastFrame
    // autoLoad: true
    fillMode: VideoOutput.PreserveAspectFit
    // flushMode: VideoOutput.LastFrame
    // audioRole: MediaPlayer.VideoRole
}

