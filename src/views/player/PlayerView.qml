import QtQuick
import QtMultimedia
import QtQuick.Layouts

import QtQuick.Controls

import org.mauikit.controls as Maui

import org.maui.clip as Clip

Clip.Video
{
    id: control
    url: currentVideo.url

    property alias player : control

    property var currentVideo : ({})
    property int currentVideoIndex : -1

    Connections
    {
        target: control.player

        function onPlaybackStateChanged()
        {

            if(control.playing)
            {
                Clip.LockManager.setInhibitionOn(i18n("Playing mode"));

            }else
            {
                Clip.LockManager.setInhibitionOff();
            }
        }
    }
}

