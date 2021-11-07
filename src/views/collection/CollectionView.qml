import QtQuick.Controls 2.13
import org.maui.clip 1.0 as Clip

import ".."

BrowserLayout
{
    id: control

    list.urls: Clip.Clip.sources

    holder.emoji: "qrc:/img/assets/view-media-video.svg"
    holder.title: i18n("No Videos!")
    holder.body: i18n("Add a new video source or open a file.")
    holder.actions:[

        Action
        {
            text: i18n("Open file")
            onTriggered: openFileDialog()
        },

        Action
        {
            text: i18n("Add sources")
            onTriggered: openSettingsDialog()
        }
    ]

    onItemClicked:
    {
        play(item)
    }    
}
