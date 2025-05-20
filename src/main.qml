import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts

import QtMultimedia

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.clip as Clip

import "views"
import "views/player"
import "views/collection"
import "views/tags"
import "views/settings"
import "views/youtube"

Maui.ApplicationWindow
{
    id: root

    Maui.Style.styleType: _sideBarView.active ? Maui.Style.Dark : undefined

    title: _playerView.currentVideo.label

    property bool selectionMode : false

    readonly property alias player: _playerView

    //    onIsPortraitChanged:
    //    {
    //        if(!isPortrait)
    //        {
    //            root.showFullScreen()
    //        }
    //        else
    //        {
    //            root.showNormal()
    //        }
    //    }

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

    Loader
    {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: DropArea
        {
            onDropped: (drop) =>
                       {
                           if(drop.urls)
                           {
                               Clip.Clip.openVideos(drop.urls)
                           }
                       }
        }
    }

    Component
    {
        id: removeDialogComponent

        FB.FileListingDialog
        {
            title: i18n("Delete files?")
            message: i18n("Are sure you want to delete %1 files", urls.length)
            template.iconSource: "emblem-warning"
            onClosed: destroy()

            actions: [

                Action
                {
                    text: i18n("Delete")
                    Maui.Controls.status: Maui.Controls.Negative
                    onTriggered:
                    {
                        for(var url of urls)
                            FB.FM.removeFile(url)

                        close()
                    }
                },

                Action
                {
                    text: i18n("Cancel")
                    onTriggered: close()
                }
            ]

        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _openUrlDialogComponent
        Maui.InputDialog
        {
            title: i18n("Open URL")
            textEntry.placeholderText: "URL"
            message: i18n("Enter any remote location, like YouTube video URLs, or from other services supported by MPV.")
            onAccepted: player.url = textEntry.text
            onClosed: destroy()
        }
    }

    property QtObject tagsDialog : null
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
            browser.settings.filterType: FB.FMList.VIDEO
            onClosed: destroy()
        }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent
        initialItem: initModule === "viewer" ? _sideBarView : _appViewsComponent
        Maui.Theme.colorSet: Maui.Theme.View

        Component
        {
            id: _appViewsComponent

            CollectionView
            {
                FloatingVideo
                {
                    id: _floatingViewer

                    DragHandler
                    {
                        target: _floatingViewer
                        xAxis.maximum: _floatingViewer.parent.width - _floatingViewer.width
                        xAxis.minimum: 0

                        yAxis.maximum : _floatingViewer.parent.height - _floatingViewer.height
                        yAxis.minimum: 0

                        onActiveChanged:
                        {
                            if(!active)
                            {
                                let newX = Math.abs(_floatingViewer.x - (_floatingViewer.parent.width - _floatingViewer.implicitWidth - 20))
                                _floatingViewer.y = Qt.binding(()=> { return _floatingViewer.parent.height - _floatingViewer.implicitHeight - 20})
                                _floatingViewer.x = Qt.binding(()=> { return (_floatingViewer.parent.width - _floatingViewer.implicitWidth - 20 - newX) < 0 ? 20 : _floatingViewer.parent.width - _floatingViewer.implicitWidth - 20 - newX})
                            }
                        }
                    }
                }
            }
        }

        Maui.SideBarView
        {
            id: _sideBarView
            focus: true
            readonly property bool active: StackView.status === StackView.Active

            sideBar.collapsed: true
            sideBar.floats: sideBar.collapsed
            sideBar.enabled: _playlist.count > 1
            sideBar.autoHide: true
            sideBar.autoShow: false
            sideBar.preferredWidth: 200
            sideBar.minimumWidth: 200
            background:  null
            sideBarContent: Item
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.contentMargins

                Maui.Page
                {
                    title: i18n("Now playing")
                    showTitle: true
                    anchors.fill: parent

                    headBar.visible: _playlist.count > 0
                    headBar.background: null

                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }

                    headBar.rightContent: ToolButton
                    {
                        icon.name: "edit-delete"
                        onClicked:
                        {
                            player.stop()
                            _playlist.list.clear()
                        }
                    }

                    headBar.leftContent: ToolButton
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
                id: _playerPage
                anchors.fill: parent
                autoHideHeader: _playerView.playbackState === MediaPlayer.PlayingState
                //                autoHideFooter: _playerView.player.playbackState === MediaPlayer.PlayingState

                headerMargins: Maui.Style.defaultPadding
                floatingHeader: true
                headBar.visible: !_playerHolderLoader.active

                Maui.Controls.showCSD: true

                onGoBackTriggered: _stackView.pop()

                Keys.enabled: !Maui.Handy.isMobile
                Keys.onSpacePressed: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                Keys.onLeftPressed: player.seek(player.position - 500)
                Keys.onRightPressed: player.seek(player.position + 500)

                PlayerView
                {
                    id: _playerView
                    anchors.fill: parent
                }

                // BusyIndicator
                // {
                //     anchors.centerIn: parent
                //     running: _playerView.status === MediaPlayer.Loading
                // }

                Loader
                {
                    anchors.fill: parent
                    asynchronous: true
                    //                active: !player.stopped

                    sourceComponent: RowLayout
                    {
                        MouseArea
                        {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            onDoubleClicked: player.seek(player.position - 5)
                        }

                        MouseArea
                        {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                            onDoubleClicked: root.toggleFullScreen()
                        }

                        MouseArea
                        {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            onDoubleClicked: player.seek(player.position + 5)
                        }
                    }
                }

                Loader
                {
                    id: _playerHolderLoader
                    anchors.fill: parent
                    active: _playerView.isStopped && _playerView.error !== MediaPlayer.NoError
                    asynchronous: true
                    visible: active
                    sourceComponent: Maui.Holder
                    {
                        emoji: "qrc:/img/assets/media-playback-start.svg"
                        title: i18n("Nothing Here!")
                        body: _playerView.error !== MediaPlayer.NoError ? _playerView.erroString : i18n("Open a new video from your collection or file system.")
                        actions: [

                            Action
                            {
                                text: "Open"
                                onTriggered: root.openFileDialog()
                            },

                            Action
                            {
                                text: "Collection"
                                onTriggered: toggleViewer()
                            }
                        ]
                    }
                }

                headBar.leftContent: ToolButton
                {
                    text: i18n("Collection")
                    icon.name: "go-previous"
                    onClicked: toggleViewer()
                }

                headBar.rightContent: [

                    FB.FavButton
                    {
                        url: _playerView.source
                    },

                    ToolButton
                    {
                        //                        text: i18n("Open")
                        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
                        icon.name: "folder-open"
                        onClicked: root.openFileDialog()
                    },
                    Loader
                    {
                        active: Clip.Clip.mpvAvailable
                        asynchronous: true
                        sourceComponent:  Maui.ToolButtonMenu
                        {
                            icon.name: "overflow-menu"

                            Maui.MenuItemActionRow
                            {
                                Action
                                {
                                    icon.name: "edit-share"
                                }

                                Action
                                {
                                    icon.name: "edit"
                                }

                                Action
                                {
                                    icon.name: "view-fullscreen"
                                    onTriggered: toggleFullscreen()
                                }
                            }

                            MenuSeparator{}

                            MenuItem
                            {
                                text: "Corrections"
                                onTriggered: control.editing = !control.editing
                            }

                            MenuItem
                            {
                                text: "Subtitles"
                                onTriggered: _subtitlesDialog.open()
                            }

                            MenuItem
                            {
                                text: "Audio"
                                onTriggered: _audioTracksDialog.open()
                            }
                        }
                    }]

                // footBar.visible: _sideBarView.sideBar.enabled
                footBar.farLeftContent: Loader
                {
                    active: _sideBarView.sideBar.enabled
                    visible: active
                    asynchronous: true
                    sourceComponent: ToolButton
                    {
                        icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                        onClicked: _sideBarView.sideBar.toggle()
                        checked: _sideBarView.sideBar.visible
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        ToolTip.text: i18n("Toggle SideBar")
                    }
                }

                // footBar.background: Rectangle
                // {
                //     color: Maui.Theme.backgroundColor
                //     opacity: 0.88
                //     radius: Maui.Style.radiusV
                // }

                floatingFooter: true
                footerMargins: Maui.Style.defaultPadding
                footBar.middleContent: Slider
                {
                    id: _slider
                    Layout.fillWidth: true
                    padding: 0
                    orientation: Qt.Horizontal
                    from: 0
                    to: player.duration
                    value: player.position
                    Layout.preferredHeight: 22
                    onMoved: player.seek( _slider.value )
                    spacing: 0
                    focus: true
                }

                footBar.rightContent: [Label
                    {
                        text: Maui.Handy.formatTime(player.duration/1000) + " / " +Maui.Handy.formatTime(player.position/1000)
                    },

                    ToolButton
                    {
                        icon.name: "zoom-fit-width"
                        checkable: true
                        checked: player.fillMode == VideoOutput.PreserveAspectFit
                        onClicked:
                        {
                            if(!checked)
                                player.fillMode = VideoOutput.PreserveAspectCrop
                            else
                                player.fillMode = VideoOutput.PreserveAspectFit
                        }
                    }

                ]

                footBar.leftContent: Maui.ToolActions
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
                        icon.name: player.isPlaying ? "media-playback-pause" : "media-playback-start"
                        onTriggered: player.isPaused ? player.play() : player.pause()
                    }

                    Action
                    {
                        icon.name: "media-skip-forward"
                        onTriggered: playNext()
                    }
                }

            }
        }
    }

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

    function toggleViewer()
    {
        if(_sideBarView.active)
        {
            if(_stackView.depth === 1)
            {
                _stackView.replace(_sideBarView, _appViewsComponent)

            }else
            {
                _stackView.pop()
            }

        }else
        {
            _stackView.push(_sideBarView)
        }

        _stackView.currentItem.forceActiveFocus()
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
            _playerView.currentVideoIndex = index
            _playerView.currentVideo = _playlist.model.get(index)

            if(!_sideBarView.active)
            {
                toggleViewer()
            }

            _playerView.play()
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

    function openFileDialog()
    {
        var props = ({'callback' : function(paths)
        {
            Clip.Clip.openVideos(paths)
        }})

        var dialog = fmDialogComponent.createObject(root, props)
        dialog.open()
    }

    function openSettingsDialog()
    {
        var dialog = _settingsDialogComponent.createObject(root)
        dialog.open()
    }

    function tagFiles(urls)
    {
        if(!tagsDialog)
        {
            tagsDialog = tagsDialogComponent.createObject(root)
        }
        tagsDialog.composerList.urls = urls
        tagsDialog.open()
    }

    function saveFiles(urls)
    {
        var props = ({  'browser.settings.onlyDirs' : true,
                         'singleSelection' : true,
                         'callback' : function(paths)
                         {
                             FB.FM.copy(urls, paths[0])
                         }})
        var dialog = fmDialogComponent.createObject(root, props)
        dialog.open()
    }

    function removeFiles(urls)
    {
        var dialog = removeDialogComponent.createObject(root, ({'urls':urls}))
        dialog.open()
    }
}
