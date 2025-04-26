import QtQuick
import QtMultimedia
import QtQuick.Layouts

import QtQuick.Controls

import org.mauikit.controls as Maui

import org.maui.clip as Clip

Player
{
    id: control
    // source: currentVideo.url
    readonly property alias player : control
    url: currentVideo.url ? currentVideo.url : ""
    property var currentVideo : ({})
    property int currentVideoIndex : -1
    // orientation : 90
    // autoLoad: true


    // readonly property bool isPlaying : control.playbackState === MediaPlayer.PlayingState
    // readonly property bool isPaused : control.playbackState === MediaPlayer.PausedState
    // readonly property bool isStopped : control.playbackState === MediaPlayer.StoppedState

    // Connections
    // {
    //     target: control.player

    //     function onPlaybackStateChanged()
    //     {
    //         if(control.playing)
    //         {
    //             Clip.LockManager.setInhibitionOn(i18n("Playing mode"));

    //         }else
    //         {
    //             Clip.LockManager.setInhibitionOff();
    //         }
    //     }
    // }
}

