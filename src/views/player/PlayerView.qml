import QtQuick 2.14
import QtQuick.Window 2.13
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.8 as Kirigami
import QtMultimedia 5.8

Item
{
    id: control
    property alias url : _player.url
    property alias player : _player

    property var currentVideo : ({})
    property int currentVideoIndex : -1

    onCurrentVideoChanged:
    {
        url = currentVideo.url
    }

    Player
    {
        id: _player
        anchors.fill: parent

        Maui.Holder
        {
            visible: player.stopped && player.video.status === MediaPlayer.NoMedia
            emojiSize: Maui.Style.iconSizes.huge
            emoji: "qrc:/img/assets/view-media-video.svg"
            title: i18n("No Videos!")
            body: i18n("Open a new video to start playing or add it to the playlist.")
        }
    }

}
