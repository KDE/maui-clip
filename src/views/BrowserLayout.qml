import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

import org.maui.clip 1.0 as Clip
import QtMultimedia 5.8

Maui.AltBrowser
{
    id: control
    property alias list : _collectionList
    property alias urls : _collectionList.urls
    property alias listModel : _collectionModel
    property alias searchField:  _searchField

    signal itemClicked(var item)
    signal itemRightClicked(var item)

    headBar.forceCenterMiddleContent: false
    gridView.itemSize: 180

    enableLassoSelection: true

    holder.visible: _collectionList.count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge

    viewType: control.width < Maui.Style.units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid

    Connections
    {
        target: control.currentView
        ignoreUnknownSignals: true

        function onItemsSelected(indexes)
        {
            for(var i in indexes)
                selectionBar.insert(_collectionModel.get(indexes[i]))
        }

        function onKeyPress(event)
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                control.currentView.itemsSelected([index])
            }
        }
    }

    ItemMenu
    {
        id: _menu
        index: control.currentIndex
        model: control.model
    }

    headBar.middleContent: Maui.SearchField
    {
        id: _searchField
        enabled: _collectionList.count > 0
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter

        placeholderText: i18np("Search %1 video", "Search %1 videos", _collectionList.count)
        onAccepted: _collectionModel.filter = text
        onCleared: _collectionModel.filter = ""
    }

    model: Maui.BaseModel
    {
        id: _collectionModel
        sortOrder: settings.sortOrder
        sort: settings.sortBy
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Clip.Videos
        {
            id: _collectionList
            urls: ["collection:///"]
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

        onClicked: (mouse) =>
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                control.itemClicked(listModel.get(index))
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                control.itemClicked(listModel.get(index))
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
                return

            control.currentIndex = index
            control.itemRightClicked(listModel.get(index))
            _menu.show()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(listModel.get(index))
            _menu.show()
        }

        Connections
        {
            target: selectionBar

            function onUriRemoved(uri)
            {
                if(uri === model.url)
                    _listDelegate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.url)
                    _listDelegate.checked = true
            }

            function onCleared(uri)
            {
                _listDelegate.checked = false
            }
        }
    }

    gridDelegate: Item
    {
        readonly property bool isCurrentItem : GridView.isCurrentItem
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        property bool preview : false

        Timer
        {
            id:  _timer
            interval: 1500
            onTriggered: parent.preview = true
        }

        Maui.GridBrowserDelegate
        {
            id: delegate

            onHoveredChanged:
            {
                if(hovered)
                {
                    _timer.start()
                }else
                {
                    _timer.stop()
                    preview = false
                }
            }

            iconSizeHint: Maui.Style.iconSizes.big
            label1.text: model.label

            anchors.centerIn: parent
            height: control.gridView.cellHeight - 15
            width: control.gridView.itemSize - 20
            padding: Maui.Style.space.tiny
            isCurrentItem: parent.isCurrentItem || checked
            tooltipText: model.url
            checkable: root.selectionMode
            checked: (selectionBar ? selectionBar.contains(model.url) : false)
            draggable: true

            Drag.keys: ["text/uri-list"]
            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.url)
                               } : {}

        template.iconComponent: Loader
        {
            sourceComponent: preview && !Maui.Handy.isMobile ? videoComponent : imgComponent

            Component
            {
                id: videoComponent
                Video
                {
                    autoPlay: true
                    // autoLoad: true
                    source: model.url
                    muted: true
                    fillMode: VideoOutput.PreserveAspectFit
                    playbackRate: 5.0
                    loops: 3
                    // flushMode: VideoOutput.LastFrame
                }
            }

            Component
            {
                id: imgComponent
                Maui.IconItem
                {
                    imageSource: model.preview
                    iconSource: model.icon
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        onClicked: (mouse) =>
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                control.itemClicked(listModel.get(index))
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                control.itemClicked(listModel.get(index))
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
                return

            control.currentIndex = index
            control.itemRightClicked(listModel.get(index))
            _menu.show()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(listModel.get(index))
            _menu.show()
        }

        onToggled:
        {
            control.currentIndex = index
            control.currentView.itemsSelected([index])
        }

        onContentDropped:
        {
            //                _dropMenu.urls = drop.urls.join(",")
            //                _dropMenu.target = model.url
            //                _dropMenu.popup()
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

function filterSelectedItems(url)
{
    if(selectionBar && selectionBar.count > 0 && selectionBar.contains(url))
    {
        const uris = selectionBox.uris
        return uris.join("\n")
    }

    return url
}

}
