import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13
import QtMultimedia 5.8
import QtQml 2.14

import Qt.labs.settings 1.0

import org.kde.kirigami 2.8 as Kirigami

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.2 as FB

import org.maui.clip 1.0 as Clip

import "views"
import "views/player"
import "views/collection"
import "views/tags"
import "views/settings"
import "views/youtube"

Maui.ApplicationWindow
{
    id: root

    title: _playerView.currentVideo.label

    altHeader: Kirigami.Settings.isMobile

    floatingHeader: _appViews.currentIndex === 0 && _playerView.player.playing && !_playlist.visible
    //    autoHideHeader: _appViews.currentIndex === 0 && _playerView.player.playing

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

    Settings
    {
        id: settings
        property int volumeStep: 5
        property string colorScheme: "Breeze"
        property string sortBy: "date"
        property int sortOrder: Qt.AscendingOrder
        property bool hardwareDecoding: true
        property string preferredLanguage: "eng"
        property string subtitlesPath
        property font font
        property bool playerTagBar: true
        property string youtubeKey: "AIzaSyDMLmTSEN7i6psE2tHdaG6hy3ljWKXIYBk"
        property int youtubeQueryLimit : 50
    }


    mainMenu: [

        Action
        {
            text: i18n("Open URL")
            icon.name: "filename-space-amarok"

            onTriggered:
            {
                _openUrlDialog.open()
            }
        },

        Action
        {
            text: i18n("Settings")
            icon.name: "settings-configure"

            onTriggered:
            {
                _settingsDialog.open()
            }
        }
    ]

    /***MODELS****/
    Maui.BaseModel
    {
        id: tagsModel
        list: FB.TagsListModel
        {
            id: tagsList
        }
    }

    //    headBar.rightContent:

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                Clip.Clip.openVideos(drop.urls)
            }
        }

        onExited:
        {
            if(_appViews.currentIndex === views.player)
            {
                _appViews.goBack()
            }
        }

        onEntered:
        {
            if(drag.source)
            {
                return
            }

            _appViews.currentIndex = views.player
        }
    }

    Component
    {
        id: shareDialogComponent
        Maui.ShareDialog {}
    }

    SettingsDialog { id: _settingsDialog}

    Maui.NewDialog
    {
        id: _openUrlDialog
        title: i18n("Open URL")
        textEntry.placeholderText: "URL"
        message: i18n("Enter any remote location, like YouTube video URLs, or from other services supported by MPV.")
        onAccepted: player.url = textEntry.text
    }

    Component
    {
        id: tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        FB.FileDialog
        {
            mode: modes.SAVE
            settings.filterType: FB.FMList.IMAGE
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
                FB.FM.removeFile(url)
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

        onContentDropped:
        {
            console.log(drop.urls)
        }

        Maui.Page
        {
            anchors.fill: parent
            title: i18n("Now playing")
            showTitle: true

            headBar.visible: true
            headerBackground.color: "transparent"

            headBar.rightContent: ToolButton
            {
                icon.name: "edit-delete"
                onClicked:
                {
                    player.stop()
                    listModel.list.clear()
                    root.sync = false
                    root.syncPlaylist = ""
                }
            }

            headBar.leftContent:  ToolButton
            {
                icon.name: "document-save"
                onClicked: saveList()
            }

            Playlist
            {
                id: _playlist
                anchors.fill: parent
            }
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
            maxViews: 3

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

            YouTubeView
            {
                id: _youtubeView
                Maui.AppView.title: i18n("Online")
                Maui.AppView.iconName: "folder-cloud"
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

    //    footBar.visible: player.video.playbackState !== MediaPlayer.StoppedState

    page.footerColumn: Maui.ToolBar
    {
        visible: _appViews.currentIndex === views.player && !player.stopped
        preferredHeight: Maui.Style.rowHeightAlt

        position: ToolBar.Footer
        width: parent.width
        leftContent: Label
        {
            text: Maui.Handy.formatTime(player.video.position)
        }

        rightContent: Label
        {
            text: Maui.Handy.formatTime(player.video.duration)
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
            orientation: Qt.Horizontal
            from: 0
            to: player.video.duration
            value: player.video.position

            onMoved: player.video.seek( _slider.value )
            spacing: 0
            focus: true

            Maui.Separator
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                edge: Qt.TopEdge
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
                     height: _slider.pressed ? _slider.height : 5
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


    footBar.rightContent: [ToolButton
        {
            visible: !Kirigami.Settings.isMobile
            icon.name: "view-fullscreen"
            onClicked: toogleFullscreen()
        },

        ToolButton
        {
            text: i18n("Open")
            icon.name: "folder-open"
            display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            onClicked:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.filterType= FB.FMList.VIDEO
                dialog.settings.onlyDirs= false
                dialog.callback = function(paths)
                {
                    Clip.Clip.openVideos(paths)
                };
                dialog.open()
            }
        },

        ToolButton
        {
            icon.name: _volumeSlider.value === 0 ? "player-volume-muted" : "player-volume"
            onPressAndHold :
            {
                player.video.volume = player.video.volume === 0 ? 100 : 0
            }

            onClicked:
            {
                _sliderPopup.visible ? _sliderPopup.close() : _sliderPopup.open()
            }

            Popup
            {
                id: _sliderPopup
                height: 150
                width: parent.width
                y: -150
                x: 0
                //                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPress
                Slider
                {
                    id: _volumeSlider
                    visible: true
                    height: parent.height
                    width: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    from: 0
                    to: 100
                    value: player.video.volume
                    orientation: Qt.Vertical

                    onMoved:
                    {
                        player.video.volume = value
                    }
                }
            }
        }
    ]

    footBar.farLeftContent: ToolButton
    {
        icon.name: root.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
        onClicked: root.sideBar.toggle()

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: i18n("Toogle SideBar")
    }


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
                enabled: !player.stopped
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: player.playing ? "media-playback-pause" : "media-playback-start"
                onTriggered: player.paused ? player.video.play() : player.video.pause()
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
                _playlist.list.appendUrl(url)

            playAt(_playlist.count - urls.length)
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
