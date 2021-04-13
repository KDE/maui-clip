import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.2 as FB

import org.kde.kirigami 2.8 as Kirigami

Maui.ContextualMenu
{
    id: control

    property bool isFav : false
    property int index : -1
    property Maui.BaseModel model : null

    onOpened: isFav = FB.Tagging.isFav(control.model.get(index).url)

    MenuItem
    {
        text: i18n("Queue")
        icon.name: "media-playlist-play"
        onTriggered:
        {
            queue(model.get(index))
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Select")
        icon.name: "item-select"
        onTriggered:
        {
            if(Kirigami.Settings.isMobile)
                selectionMode = true

            selectionBar.insert(model.get(index))
        }
    }


    MenuItem
    {
        text: i18n(isFav ? "UnFav it": "Fav it")
        icon.name: "love"
        onTriggered: FB.Tagging.toggleFav(control.model.get(index).url)
    }

    MenuItem
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = [control.model.get(index).url]
            dialog.open()
        }
    }

    MenuItem
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            dialogLoader.sourceComponent = shareDialogComponent
            dialog.urls= [control.model.get(index).url]
            dialog.open()
        }
    }

    MenuItem
    {
        visible: !Maui.Handy.isAndroid
        text: i18n("Show in folder")
        icon.name: "folder-open"
        onTriggered:
        {
//            Pix.Collection.showInFolder([control.model.get(index).url])
            close()
        }
    }

    MenuItem
    {
        text: i18n("Info")
        icon.name: "documentinfo"
        onTriggered:
        {
            getFileInfo(control.model.get(index).url)
            close()
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
            close()
        }

        Maui.Dialog
        {
            id: removeDialog

            title: i18n("Delete file?")
            acceptButton.text: i18n("Accept")
            rejectButton.text: i18n("Cancel")
            message: i18n("Are sure you want to delete \n%1", control.model.get(index).url)
            page.margins: Maui.Style.space.big
            template.iconSource: "emblem-warning"

            onRejected: close()
            onAccepted:
            {
                control.model.list.deleteAt(control.index)
                close()
            }
        }
    }
}
