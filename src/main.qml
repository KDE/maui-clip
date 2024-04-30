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

    title: _playerView.currentVideo.label

    property bool selectionMode : false

    readonly property alias dialog : dialogLoader.item
    readonly property alias player: _playerView.player

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
        id: _settingsDialogComponent
        SettingsDialog {}
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
        }
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
            browser.settings.filterType: FB.FMList.IMAGE
            browser.settings.onlyDirs: false
        }
    }

    Component
    {
        id: removeDialogComponent

        Maui.InfoDialog
        {
            title: i18n("Delete files?")

            message: i18n("Are sure you want to delete %1 files", String(selectionBar.count))
            standardButtons: Dialog.Ok | Dialog.Cancel
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
    }

    Loader { id: dialogLoader }

    StackView
    {
        id: _stackView
        anchors.fill: parent
        initialItem: initModule === "viewer" ? _sideBarView : _appViewsComponent

        Component
        {
            id: _appViewsComponent

            CollectionView  {}
        }

        Maui.SideBarView
        {
            id: _sideBarView
            focus: true

            visible: StackView.status === StackView.Active

            height: parent.height
            width: parent.width

            sideBar.enabled: _playlist.count > 1
            sideBar.autoHide: true
            sideBar.autoShow: false
            sideBar.preferredWidth: Maui.Style.units.gridUnit * 16

            sideBarContent: Maui.Page
            {
                anchors.fill: parent
                title: i18n("Now playing")
                showTitle: true

                headBar.visible: _playlist.count > 0
                headBar.background: null

                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: 0.2
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

            Maui.Page
            {
                id: _playerPage
                anchors.fill: parent
                autoHideHeader: _playerView.player.playbackState === MediaPlayer.PlayingState
                //                autoHideFooter: _playerView.player.playbackState === MediaPlayer.PlayingState

                floatingHeader: autoHideHeader
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

                BusyIndicator
                {
                    anchors.centerIn: parent
                    running: _playerView.status === MediaPlayer.Loading
                }

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
                    active: _playerView.stopped && _playerView.status === MediaPlayer.NoMedia
                    asynchronous: true
                    visible: active
                    sourceComponent: Maui.Holder
                    {
                        emoji: "qrc:/img/assets/media-playback-start.svg"
                        title: i18n("Nothing Here!")
                        body: i18n("Open a new video from your collection or file system.")
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

                footerColumn: Loader
                {
                    active: !player.stopped
                    width: parent.width
                    asynchronous: true
                    visible: active

                    sourceComponent: Maui.ToolBar
                    {
                        preferredHeight: Maui.Style.rowHeightAlt

                        position: ToolBar.Footer
                        leftContent: Label
                        {
                            text: Maui.Handy.formatTime(player.video.position/1000)
                        }

                        rightContent: Label
                        {
                            text: Maui.Handy.formatTime(player.video.duration/1000)
                        }

                        middleContent: Item
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
                                color: Maui.Theme.textColor
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
                                width: parent.width
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
                                    height: _slider.pressed ? _slider.height : 2
                                    color: Maui.Theme.highlightColor
                                }
                            }

                            handle: Rectangle
                            {
                                x: _slider.leftPadding + _slider.visualPosition
                                   * (_slider.availableWidth - width)
                                y: 0
                                implicitWidth: Maui.Style.iconSizes.medium
                                implicitHeight: _slider.height
                                color: _slider.pressed ? Qt.lighter(Maui.Theme.highlightColor, 1.2) : "transparent"
                            }
                        }
                    }
                }

                headBar.rightContent: [
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

                footBar.visible: _sideBarView.sideBar.enabled
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

                footBar.middleContent: [

                    Maui.ToolActions
                    {
                        Layout.alignment: Qt.AlignCenter
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
                            icon.name: player.playing ? "media-playback-pause" : "media-playback-start"
                            onTriggered: player.paused ? player.video.play() : player.video.pause()
                        }

                        Action
                        {
                            icon.name: "media-skip-forward"
                            onTriggered: playNext()
                        }
                    }
                ]
            }
        }
    }

    Loader
    {
        visible: active
        active: !_sideBarView.visible && !_playerView.player.stopped
        asynchronous: true
        sourceComponent: FloatingVideo {}
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
        if(_sideBarView.visible)
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

            if(!_playerView.visible)
            {
                toggleViewer()
            }
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

    function openSettingsDialog()
    {
        dialogLoader.sourceComponent = _settingsDialogComponent
        dialog.open()
    }

}
