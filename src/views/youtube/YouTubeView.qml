import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import ".."

import org.maui.clip 1.0 as Clip

Maui.AltBrowser
{
    id: control

    signal itemClicked(var item)
    signal itemRightClicked(var item)

    gridView.itemSize: 180

    viewType: control.width < Kirigami.Units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid

    holder.visible: control.currentView.count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.emoji: "qrc:/img/assets/help-feedback.svg"
    holder.title: i18n("Nothing Here!")
    holder.body: i18n("Start searching for online videos.")

    model : Maui.BaseModel
    {
        id: _youtubeModel
        list: Clip.YouTube
        {
            id: _youtubeList
            key: settings.youtubeKey
            limit: settings.youtubeQueryLimit
        }
    }

    headBar.middleContent: Maui.TextField
    {
        id: _searchField
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Search...")
        onAccepted:
        {
            _youtubeList.query = text
        }
    }

    listDelegate: ListDelegate
    {
        id: _listDelegate
        width: ListView.view.width

        onToggled:
        {
            control.currentIndex = index
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
                play(_youtubeModel.get(index))
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                play(_youtubeModel.get(index))
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
                return

            control.currentIndex = index
            control.itemRightClicked(index)
            _menu.popup()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(index)
            _menu.popup()
        }
    }

    gridDelegate: Item
    {
        property bool isCurrentItem : GridView.isCurrentItem
        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        Maui.GridBrowserDelegate
        {
            id: delegate

            iconSizeHint: height * 0.6
            label1.text: model.label
            imageSource: model.thumbnail
            template.fillMode: Image.PreserveAspectFit

            anchors.centerIn: parent
            height: control.gridView.cellHeight - 15
            width: control.gridView.itemSize - 20
            padding: Maui.Style.space.tiny
            isCurrentItem: parent.isCurrentItem
            tooltipText: model.url
            checkable: root.selectionMode
            checked: (selectionBar ? selectionBar.contains(model.url) : false)
            draggable: true
            opacity: model.hidden == "true" ? 0.5 : 1

            Drag.keys: ["text/uri-list"]
            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.url)
                               } : {}

        onClicked:
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                play(_youtubeModel.get(index))
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                play(_youtubeModel.get(index))
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
                return

            control.currentIndex = index
            control.itemRightClicked(model)
            _menu.popup()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(model)
            _menu.popup()
        }

        onToggled:
        {
            control.currentIndex = index
            control.currentView.itemsSelected([index])
        }

        Connections
        {
            target: selectionBar

            function onUriRemoved(uri)
            {
                if(uri === model.url)
                    delegate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.url)
                    delegate.checked = true
            }

            function onCleared(uri)
            {
                delegate.checked = false
            }
        }
    }
}



function watchVideo(track)
{
    if(track && track.url)
    {
        var url = track.url
        if(url && url.length > 0)
        {
            youtubeViewer.currentYt = track
            youtubeViewer.webView.url = url+"?autoplay=1"
            stackView.push(youtubeViewer)

        }
    }
}

function playTrack(url)
{
    if(url && url.length > 0)
    {
        var newURL = url.replace("embed/", "watch?v=")
        console.log(newURL)
        webView.url = newURL+"?autoplay=1+&vq=tiny"
        webView.runJavaScript("document.title", function(result) { console.log(result); });
    }
}

function runSearch(searchTxt)
{
    if(searchTxt)
        if(searchTxt !== youtubeTable.title)
        {
            youtubeTable.title = searchTxt
            Vvave.YouTube.getQuery(searchTxt, Maui.Handy.loadSettings("YOUTUBELIMIT", "BABE", 25))
        }
}

function clearSearch()
{
    searchInput.clear()
    youtubeTable.listView.model.clear()
    youtubeTable.title = ""
    searchRes = []
}

function populate(tracks)
{
    youtubeTable.model.clear()
    for(var i in tracks)
        youtubeTable.model.append(tracks[i])
}
}
