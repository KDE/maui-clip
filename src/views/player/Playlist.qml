import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.clip 1.0 as Clip

import ".."

Maui.ListBrowser
{
    id: control

    property alias list : _collectionList
    property alias listModel: _collectionModel

    holder.visible: list.count === 0
    holder.emoji: "qrc:/img/assets/media-playlist-append.svg"
    holder.title: i18n("No Videos!")
    holder.body: i18n("Add videos to the playlist.")

    Binding on currentIndex
    {
        value: _playerView.currentVideoIndex
        restoreMode: Binding.RestoreBindingOrValue
    }

    topMargin: Maui.Style.contentMargins
    spacing: Maui.Style.space.big

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

    delegate: ListDelegate
    {
        id: _listDelegate
        width: ListView.view.width
        implicitHeight: Maui.Style.rowHeight * 1.5

        onToggled:
        {
            control.currentView.itemsSelected([index])
        }

        onClicked:
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

