import QtQuick 2.14
import QtMultimedia 5.8
import QtQuick.Layouts 1.3

import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.clip 1.0 as Clip

Clip.Video
{
    id: control
    url: currentVideo.url

    property alias player : control

    property var currentVideo : ({})
    property int currentVideoIndex : -1

    Keys.enabled: true
    Keys.onSpacePressed: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
    Keys.onLeftPressed: player.seek(player.position - 50)
    Keys.onRightPressed: player.seek(player.position + 50)

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"

    Loader
    {
        anchors.fill: parent
        active: control.stopped && control.status === MediaPlayer.NoMedia
        visible: active
        asynchronous: true
        sourceComponent: Maui.Holder
        {
            emojiSize: Maui.Style.iconSizes.huge
            emoji: "qrc:/img/assets/media-playback-start.svg"
            title: i18n("Nothing Here!")
            body: i18n("Open a new video to start playing or add it to the playlist.")
        }
    }

    BusyIndicator
    {
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        Kirigami.Theme.inherit: false

        anchors.centerIn: parent
        running: control.status === MediaPlayer.Loading
    }

    Loader
    {
        anchors.fill: parent
        asynchronous: true
        active: !control.stopped

        sourceComponent: RowLayout
        {

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position - 5)
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                onDoubleClicked: root.toggleFullScreen()
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position + 5)
            }
        }
    }
}

