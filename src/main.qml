import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtMultimedia 5.8

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
    headBar.visible: false

    property bool selectionMode : false

    readonly property var views : ({player: 0, collection: 1, tags: 2})
    property alias dialog : dialogLoader.item
    property alias player: _playerView.player

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: root.background.radius
        enabled: !Kirigami.Settings.isMobile
    }

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

    Loader
    {
        anchors.fill: parent

        asynchronous: true

        sourceComponent:  DropArea
        {
            onDropped:
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
        Maui.NewDialog
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
            settings.filterType: FB.FMList.IMAGE
            settings.onlyDirs: false
        }
    }

    Component
    {
        id: removeDialogComponent

        Maui.Dialog
        {
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
    }

    Loader { id: dialogLoader }

    sideBar: Maui.AbstractSideBar
    {
        enabled: _playlist.count > 1
        preferredWidth: Kirigami.Units.gridUnit * 16
        collapsed: !isWide
        collapsible: true

        Maui.Page
        {
            anchors.fill: parent
            title: i18n("Now playing")
            showTitle: true

            headBar.visible: _playlist.count > 0
            headBar.background: null
            background: Rectangle
            {
                color: Kirigami.Theme.backgroundColor
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
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: Maui.Page
        {
            Maui.AppView.title: i18n("Player")
            Maui.AppView.iconName: "media-playback-start"
            headBar.visible: !_playerHolderLoader.active

            showCSDControls: true

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
                active: !control.stopped

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
                            onTriggered: _stackView.push(_appViewsComponent)
                        }

                    ]
                }
            }

            headBar.leftContent: ToolButton
            {
                text: i18n("Collection")
                icon.name: "go-previous"
                onClicked: _stackView.push(_appViewsComponent)
            }

            headBar.rightContent: ToolButton
            {
                text: i18n("Open")
                icon.name: "folder-open"
                onClicked: root.openFileDialog()
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

                        Kirigami.Separator
                        {
                            anchors.top: parent.top
                            width: parent.width
                            height: 0.5
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
            }

            footBar.rightContent: Loader
            {
                active: !Kirigami.Settings.isMobile
                visible: active
                asynchronous: true
                sourceComponent: ToolButton
                {
                    icon.name: "view-fullscreen"
                    onClicked: toggleFullscreen()
                }
            }

            footBar.farLeftContent:  Loader
            {
                active: root.sideBar.enabled
                visible: active
                asynchronous: true
                sourceComponent: ToolButton
                {
                    icon.name: root.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                    onClicked: root.sideBar.toggle()
                    checked: root.sideBar.visible
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Toggle SideBar")
                }
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
                }
            ]

        }

        Component
        {
            id: _appViewsComponent

            Maui.AppViews
            {
                id: _appViews
                anchors.fill: parent
                maxViews: 4
                floatingFooter: true
                flickable: _appViews.currentItem.item.flickable
                showCSDControls: true

                altHeader: Kirigami.Settings.isMobile

                headBar.leftContent: Maui.ToolButtonMenu
                {
                    icon.name: "application-menu"

                    //            MenuItem
                    //            {
                    //                text: i18n("Open URL")
                    //                icon.name: "filename-space-amarok"

                    //                onTriggered:
                    //                {
                    //                    _openUrlDialog.open()
                    //                }
                    //            }

                    MenuItem
                    {
                        text: i18n("Settings")
                        icon.name: "settings-configure"

                        onTriggered:
                        {
                            dialogLoader.sourceComponent = _settingsDialogComponent
                            dialog.open()
                        }
                    }

                    MenuItem
                    {
                        text: i18n("About")
                        icon.name: "documentinfo"
                        onTriggered: root.about()
                    }
                }

                headBar.farLeftContent: ToolButton
                {
                    icon.name: "go-previous"
                    onClicked: _stackView.pop()
                }

                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Collection")
                    Maui.AppView.iconName: "folder-videos"
                    CollectionView {}
                }

                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Tags")
                    Maui.AppView.iconName: "tag"
                    TagsView {}
                }

                //            YouTubeView
                //            {
                //                id: _youtubeView
                //                Maui.AppView.title: i18n("Online")
                //                Maui.AppView.iconName: "folder-cloud"
                //            }

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
        }
    }

    Loader
    {
        visible: active
        active:_stackView.depth === 2 && !_playerView.player.stopped
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

    //    Component.onCompleted:
    //    {
    //        if(!_playerView.player.playing)
    //        {
    //            _stackView.push(_appViewsComponent)
    //        }
    //    }

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

            if(Kirigami.Settings.isMobile)
            {
                _stackView.pop()
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

}
