import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13

import QtMultimedia 5.8
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

import mpv 1.0

Maui.Page
{
    id: control
    property alias video : _mpv
    property alias url : _mpv.source

    property bool editing: false

    readonly property bool playing : _mpv.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : _mpv.playbackState === MediaPlayer.PausedState
    readonly property bool stopped :  _mpv.playbackState === MediaPlayer.StoppedState

    headBar.visible: false
    floatingFooter: player.visible && !_playlist.visible
    autoHideFooter: floatingFooter

    autoHideFooterMargins: control.height

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"
    //    Connections
    //    {
    //        target: _appViews
    //        function onCurrentIndexChanged()
    //        {
    //            if(_appViews.currentIndex !== views.player && control.playing)
    //            {
    //                player.pause()
    //            }else
    //            {
    //                player.play()
    //            }
    //        }
    //    }

    Maui.Dialog
    {
        id: _subtitlesDialog
        title: i18n("Subtitles")

        Repeater
        {
            model: _mpv.subtitleTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

    Maui.Dialog
    {
        id: _audioTracksDialog
        title: i18n("Audio Tracks")

        Repeater
        {
            model: _mpv.audioTracksModel

            Maui.ListBrowserDelegate
            {
                Layout.fillWidth: true
                label1.text: model.text
                label2.text: model.language
            }
        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        MpvObject
        {
            id: _mpv
            Layout.fillWidth: true
            Layout.fillHeight: true

            autoPlay: true
            hardwareDecoding: settings.hardwareDecoding
            onEndOfFile: playNext()

            //            visible: !control.stopped

            Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
            Keys.onLeftPressed: player.seek(player.position - 50)
            Keys.onRightPressed: player.seek(player.position + 50)

            BusyIndicator
            {
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                Kirigami.Theme.inherit: false

                anchors.centerIn: parent
                running: _mpv.status === MediaPlayer.Loading
            }

            Label
            {
                color: "orange"
                text: _mpv.status +"/"+ MediaPlayer.NoMedia
            }

            Row
            {
                visible: !control.stopped
                anchors.right: parent.right
                anchors.bottom: parent.bottom


                Maui.Badge
                {
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false

                    text: "Corrections"

                    onClicked: control.editing = !control.editing

                }

                Maui.Badge
                {
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false

                    text: "Subtitles"
                    onClicked: _subtitlesDialog.open()

                }

                Maui.Badge
                {
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Theme.inherit: false

                    text: "Audio"
                    onClicked: _audioTracksDialog.open()
                }
            }

            RowLayout
            {
                anchors.fill: parent

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
                }

                MouseArea
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onDoubleClicked: player.seek(player.position + 5)
                }
            }
        }

        Maui.Page
        {
            id: _editingView

            visible: control.editing

            //            Kirigami.Theme.colorSet: control.Kirigami.Theme.colorSet
            Kirigami.Theme.inherit: true

            implicitHeight: _editingColumn.implicitHeight + header.height + (margins *2)
            Layout.fillWidth: true
            margins: Maui.Style.space.medium

            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.editing = !control.editing
            }

            headBar.farRightContent: ToolButton
            {
                icon.name: "view-refresh"

                onClicked:
                {
                    _saturation.value = 0
                    _gamma.value = 0
                    _contrast.value = 0
                }
            }

            //            headerBackground.opacity: 0
            //            headBar.Kirigami.Theme.backgroundColor: "#333"
            //            headBar.Kirigami.Theme.textColor: "#fafafa"

            showTitle: true
            title: i18n("Corrections")

            Column
            {
                id: _editingColumn
                anchors.fill: parent

                spacing: Maui.Style.space.medium


                Column
                {
                    width: parent.width

                    Maui.ListItemTemplate
                    {
                        width: parent.width
                        label1.text: i18n("Saturation")
                        label3.text: _saturation.value
                        rightLabels.visible: true
                    }

                    Slider
                    {
                        id: _saturation
                        width: parent.width

                        wheelEnabled: true

                        from: -100
                        to: 100

                        value : 0

                        stepSize: 5
                        onValueChanged: _mpv.saturation = value
                    }
                }


                Column
                {
                    width: parent.width

                    Maui.ListItemTemplate
                    {
                        width: parent.width
                        label1.text: i18n("Contrast")
                        label3.text: _contrast.value
                        rightLabels.visible: true
                    }

                    Slider
                    {
                        id: _contrast
                        width: parent.width

                        wheelEnabled: true

                        from: -100
                        to: 100

                        value : 0

                        stepSize: 5
                        onValueChanged: _mpv.contrast = value
                    }
                }


                Column
                {
                    width: parent.width

                    Maui.ListItemTemplate
                    {
                        width: parent.width
                        label1.text: i18n("Gamma")
                        label3.text: _gamma.value
                        rightLabels.visible: true
                    }

                    Slider
                    {
                        id: _gamma
                        width: parent.width

                        wheelEnabled: true

                        from: -100
                        to: 100

                        value : 0

                        stepSize: 5
                        onValueChanged: _mpv.gamma = value
                    }
                }
            }
        }
    }

    footBar.visible: true

    footer: Maui.TagsBar
    {
        id: tagBar
        visible: root.visibility !== Window.FullScreen && settings.playerTagBar
        position: ToolBar.Footer
        width: parent.width
        allowEditMode: true
        onTagsEdited:
        {
            tagBar.list.updateToUrls(tags)
        }

        list.strict: true
        list.urls:  [control.url]
    }


}
