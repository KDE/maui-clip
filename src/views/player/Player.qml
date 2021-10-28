import QtMultimedia 5.8

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
    autoLoad: true

    flushMode: VideoOutput.LastFrame

}

