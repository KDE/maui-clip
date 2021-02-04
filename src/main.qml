import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13
import QtMultimedia 5.8
import QtQml 2.14

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.clip 1.0 as Clip

import TagsList 1.0

import "views"
import "views/player"
import "views/collection"
import "views/tags"

Maui.ApplicationWindow
{
    id: root

    title: _playerView.currentVideo.label

    altHeader: Kirigami.Settings.isMobile

    floatingHeader: _appViews.currentIndex === 0 && _playerView.player.playing && !_playlist.visible
    autoHideHeader: _appViews.currentIndex === 0 && _playerView.player.playing

    property bool selectionMode : false

    readonly property var views : ({player: 0, collection: 1, tags: 2})
    property alias dialog : dialogLoader.item
    property alias player: _playerView.player


//    floatingFooter: true
    flickable: _appViews.currentItem ? _appViews.currentItem.flickable || null : null

    headBar.visible: root.visibility !== Window.FullScreen

    onIsPortraitChanged:
    {
        if(!isPortrait)
        {
            root.showFullScreen()
        }
        else
        {
            root.showNormal()
        }
    }

    /***MODELS****/
    Maui.BaseModel
    {
        id: tagsModel
        list: TagsList
        {
            id: tagsList
        }
    }

    headBar.farLeftContent: ToolButton
    {
        visible: !root.isWide
        onClicked: sideBar.open()
        icon.name: "love"
    }

    mainMenu: [
        Action
        {
            text: i18n("Open")
            icon.name: "folder-open"
            onTriggered:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.filterType= Maui.FMList.VIDEO
                dialog.settings.onlyDirs= false
                dialog.callback = function(paths)
                {
                    Clip.Clip.openVideos(paths)
                };
                dialog.open()
            }
        }
    ]

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                VIEWER.openExternalPics(drop.urls, 0)
            }
        }

        onExited:
        {
            if(swipeView.currentIndex === views.viewer)
            {
                swipeView.goBack()
            }
        }

        onEntered:
        {
            if(drag.source)
            {
                return
            }

            swipeView.currentIndex = views.viewer
        }
    }

    Component
    {
        id: shareDialogComponent
        Maui.ShareDialog {}
    }

    Component
    {
        id: tagsDialogComponent
        Maui.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        Maui.FileDialog
        {
            mode: modes.SAVE
            settings.filterType: Maui.FMList.IMAGE
            settings.onlyDirs: false
        }
    }

    Maui.Dialog
    {
        id: removeDialog

        title: i18n("Delete files?")
        acceptButton.text: i18n("Accept")
        rejectButton.text: i18n("Cancel")
        message: i18n("Are sure you want to delete %1 files", String(selectionBar.count))
        page.margins: Maui.Style.space.big
        template.iconSource: "emblem-warning"
        onRejected: close()
        onAccepted:
        {
            for(var url of selectionBox.uris)
                Maui.FM.removeFile(url)
            selectionBox.clear()
            close()
        }
    }

    Loader { id: dialogLoader }

    sideBar: Maui.AbstractSideBar
    {
        visible: true
        preferredWidth: Kirigami.Units.gridUnit * 16
        collapsed: !isWide
        collapsible: true


//        Binding on visible
//        {
//            restoreMode: Binding.RestoreValue
//            value: _playlist.list.count > 0 && root.visibility !== Window.FullScreen
//        }

        Playlist
        {
            id: _playlist
            anchors.fill: parent
        }
    }

    Maui.Page
    {
        id: _mainPage
        anchors.fill: parent
        floatingFooter: true
        headBar.visible: false
        flickable: _appViews.currentItem.flickable || _appViews.currentItem.item.flickable

        Maui.AppViews
        {
            id: _appViews
            anchors.fill: parent

            PlayerView
            {
                id: _playerView
                Maui.AppView.title: i18n("Player")
                Maui.AppView.iconName: "quickview"
            }

            CollectionView
            {
                id: _collectionView
                Maui.AppView.title: i18n("Collection")
                Maui.AppView.iconName: "folder-videos"
            }

            TagsView
            {
                id: _tagsView
                Maui.AppView.title: i18n("Tags")
                Maui.AppView.iconName: "tag"
            }
        }

        footer: SelectionBar
        {
            id: selectionBar
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            padding: Maui.Style.space.big
            maxListHeight: _appViews.height - Maui.Style.space.medium
        }

    }


    page.footerColumn: Maui.ToolBar
    {
        preferredHeight: Maui.Style.rowHeight

        enabled: player.playbackState !== MediaPlayer.StoppedState
        position: ToolBar.Footer
        width: parent.width
        leftContent: Label
        {
            text: Maui.FM.formatTime((player.video.duration - player.video.position)/1000)
        }

        rightContent: Label
        {
            text: Maui.FM.formatTime(player.video.duration/1000)
        }


        middleContent:  Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Label
            {
                anchors.fill: parent
                visible: text.length
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: root.title
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: Kirigami.Theme.textColor
            }
        }

        background: Slider
        {
            id: _slider
            z: parent.z+1
            padding: 0
            enabled: control.playing || control.paused

            orientation: Qt.Horizontal
            from: 0
            to: 1000
            value: (1000 * player.video.position) / player.video.duration

            onMoved: player.video.seek((_slider.value / 1000) * player.video.duration)

            spacing: 0
            focus: true

            Maui.Separator
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                position: Qt.Horizontal
            }


            background: Rectangle
            {
                implicitWidth: _slider.width
                implicitHeight: _slider.height
                width: _slider.availableWidth
                height: implicitHeight
                color: "transparent"
                opacity: 0.4

                Rectangle
                {
                    width: _slider.visualPosition * parent.width
                    height: _slider.height
                    color: Kirigami.Theme.highlightColor
                }
            }

            handle: Rectangle
            {
                x: _slider.leftPadding + _slider.visualPosition
                   * (_slider.availableWidth - width)
                y: 0
                implicitWidth: Maui.Style.iconSizes.medium
                implicitHeight: _slider.height
                color: _slider.pressed ? Qt.lighter(Kirigami.Theme.highlightColor, 1.2) : "transparent"
            }
        }
    }


    footBar.rightContent: ToolButton
    {
        visible: !Kirigami.Settings.isMobile
        icon.name: "view-fullscreen"
        onClicked: toogleFullscreen()
        checked: fullScreen
    }

    footBar.leftContent: [
        ToolButton
        {
            icon.name: "view-split-left-right"
            checked: root.sideBar.visible
            onClicked: sideBar.position === 1 ? sideBar.close() : sideBar.open()
        },

        Maui.Badge
        {
            text: _playlist.list.count
        }
    ]

    FloatingVideo
    {
        visible: _appViews.currentIndex !== views.player && !_playerView.player.stopped
    }

    footBar.middleContent: [

        Maui.ToolActions
        {
            expanded: true
            checkable: false
            autoExclusive: false

            Action
            {
                icon.name: "media-skip-backward"
                onTriggered: playPrevious()
            }

            Action
            {
                enabled: player.video.playbackState !== MediaPlayer.StoppedState
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: player.video.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onTriggered: player.video.playbackState === MediaPlayer.PlayingState ? player.video.pause() : player.video.play()
            }

            Action
            {
                icon.name: "media-skip-forward"
                onTriggered: playNext()
            }
        }/*,

        Maui.ListItemTemplate
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            //            Layout.preferredWidth: 500
            label1.text: _playerView.currentVideo.label
            label2.text: _playerView.currentVideo.path
        }*/
    ]

    Connections
    {
        target: Clip.Clip
        function onOpenUrls(urls)
        {
            for(var url of urls)
                _playlist.list.append(url)
        }
    }

    function playNext()
    {
        if(_playlist.list.count > 0)
        {
            const next = _playerView.currentVideoIndex+1 >= _playlist.list.count ? 0 : _playerView.currentVideoIndex+1

            playAt(next)
        }
    }

    function playPrevious()
    {
        if(_playlist.list.count > 0)
        {
            const previous = _playerView.currentVideoIndex-1 >= 0 ? _playerView.currentVideoIndex-1 : _playlist.list.count-1

            playAt(previous)
        }
    }

    function play(item)
    {
        queue(item)
        playAt(_playlist.list.count-1)
    }

    //Index of the video in the playlist
    function playAt(index)
    {
        if((index < _playlist.list.count) && (index > -1))
        {
//            _appViews.currentIndex = views.player
            _playerView.currentVideoIndex = index
            _playerView.currentVideo = _playlist.model.get(index)
        }
    }

    function playItems(items)
    {
        _playlist.list.clear()
        for(var item of items)
        {
            queue(item)
        }
        playAt(0)
    }

    function queueItems(items)
    {
        for(var item of items)
        {
            queue(item)
        }
    }

    function queue(item)
    {
        _playlist.append(item)
    }

    function toogleFullscreen()
    {
        if(root.visibility === Window.FullScreen)
        {
            root.showNormal()
        }else
        {
            root.showFullScreen()
        }
    }

}
