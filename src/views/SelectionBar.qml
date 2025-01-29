import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

Maui.SelectionBar
{
    id: control

    onExitClicked:
    {
        selectionMode = false
        clear()
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        height: Maui.Style.toolBarHeight
        width: ListView.view.width

        label1.text: model.label
        label2.text: model.path
        imageSource: model.thumbnail
        iconSizeHint: height * 0.9
        checkable: true
        checked: true
        onToggled: control.removeAtIndex(index)
    }

    Action
    {
        text: i18n("Play")
        icon.name: "media-playback-start"
        onTriggered:
        {
            playItems(control.items, 0)
            control.clear()
        }
    }

    Action
    {
        text: i18n("Queue")
        icon.name: "media-playlist-play"
        onTriggered:
        {
            queueItems(control.items, 0)
            control.clear()
        }
    }

    Action
    {
        text: i18n("Un/Fav")
        icon.name: "love"
        onTriggered: VIEWER.fav(control.uris)
    }

    Action
    {
        text: i18n("Tag")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = control.uris
            dialog.open()
        }
    }

    Action
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
             Maui.Platform.shareFiles(control.uris)
        }
    }

    Action
    {
        text: i18n("Export")
        icon.name: "document-export"
        onTriggered:
        {
            const pics = control.uris
            dialogLoader.sourceComponent = null
            dialogLoader.sourceComponent = fmDialogComponent
            dialog.browser.settings.onlyDirs = true
            dialog.singleSelection = true
            dialog.callback = function(paths)
            {
                FB.FM.copy(pics, paths[0])
            }
            dialog.open()
        }
    }

    Action
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Maui.Theme.textColor: Maui.Theme.negativeTextColor
        onTriggered:
        {
            dialogLoader.sourceComponent = removeDialogComponent
            dialog.open()
        }
    }

    function insert(item)
    {
        if(control.contains(item.path))
        {
            control.removeAtUri(item.path)
            return
        }

        control.append(item.path, item)
    }
}

