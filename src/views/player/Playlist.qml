import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.mauikit.controls 1.3 as Maui
import org.maui.clip 1.0 as Clip

import ".."

Maui.ListBrowser
{
    id: control

    property alias list : _collectionList
    property alias listModel: _collectionModel

    clip: true

    holder.visible: list.count === 0
    holder.emoji: "qrc:/img/assets/media-playlist-append.svg"
    holder.title: i18n("No Videos!")
    holder.body: i18n("Add videos to the playlist.")

    Binding on currentIndex
    {
        value: _playerView.currentVideoIndex
        restoreMode: Binding.RestoreBindingOrValue
    }

    model: Maui.BaseModel
    {
        id: _collectionModel
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Clip.Videos
        {
            id: _collectionList
        }
    }

    ItemMenu
    {
        id: _menu
        index: control.currentIndex
        model: control.model
    }

    delegate: Maui.ListBrowserDelegate
    {
        id: _listDelegate
        width: ListView.view.width

        isCurrentItem: ListView.isCurrentItem
        draggable: true
        tooltipText: model.url

        label1.text: model.label
        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
        imageSource: model.thumbnail
        template.fillMode: Image.PreserveAspectCrop

        ToolButton
        {
            Layout.fillHeight: true
            Layout.preferredWidth: implicitWidth
            visible: (Maui.Handy.isTouch ? true : _listDelegate.hovered)
            icon.name: "edit-clear"
            onClicked:
            {
                if(index === _playerView.currentVideoIndex)
                    player.video.stop()

                _collectionList.remove(index)
            }

            opacity: _listDelegate.hovered ? 0.8 : 0.6
        }


        onToggled:
        {
            control.currentView.itemsSelected([index])
        }

        onClicked: (mouse) =>
        {
            control.currentIndex = index

            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                playAt(index)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index

            if(!Maui.Handy.singleClick && !selectionMode)
            {
                playAt(index)
            }
        }

        //        onPressAndHold:
        //        {
        //            control.currentIndex = index
        //            _menu.popup()
        //        }

        //        onRightClicked:
        //        {
        //            control.currentIndex = index
        //            _menu.popup()
        //        }
    }

    function append(item)
    {
        console.log("Queue item<<" , item, item.url)

        control.list.append(item)
    }
}

