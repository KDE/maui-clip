import QtQuick.Controls
import org.maui.clip as Clip

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import ".."

Maui.SideBarView
{
    id: control
    property alias urls : _browser.urls
    background: null

    sideBar.preferredWidth: 200
    sideBar.minimumWidth: 200
    sideBar.resizeable: false
    sideBar.content: PlacesSidebar
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.contentMargins
    }

    BrowserLayout
    {
        id: _browser
        anchors.fill: parent
        floatingFooter: true
        Maui.Controls.showCSD: true
        background: null
        altHeader: Maui.Handy.isMobile
        headerMargins: Maui.Style.defaultPadding
        // floatingHeader: true

        headBar.leftContent: [Maui.ToolButtonMenu
        {
            icon.name: "application-menu"

            MenuItem
            {
                enabled: Clip.Clip.mpvAvailable
                text: i18n("Open URL")
                icon.name: "filename-space-amarok"

                onTriggered:
                {
                    _openUrlDialog.open()
                }
            }

            MenuItem
            {
                text: i18n("Settings")
                icon.name: "settings-configure"

                onTriggered: openSettingsDialog()
            }

            MenuItem
            {
                text: i18n("About")
                icon.name: "documentinfo"
                onTriggered: Maui.App.aboutDialog()
            }
        },

        ToolButton
            {
                icon.name: control.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                visible: control.sideBar.collapsed

                onClicked: control.sideBar.toggle()

                checked: control.sideBar.visible

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Toggle sidebar")
            }

        ]

        holder.emoji: "qrc:/img/assets/view-media-video.svg"
        holder.title: i18n("No Videos!")
        holder.body: i18n("Add a new video source or open a file.")
        holder.actions:[

            Action
            {
                text: i18n("Open file")
                onTriggered: openFileDialog()
            },

            Action
            {
                text: i18n("Add sources")
                onTriggered: openSettingsDialog()
            }
        ]

        onItemClicked:
        {
            play(item)
        }


        footer: SelectionBar
        {
            id: selectionBar
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            maxListHeight: control.height - Maui.Style.space.medium
        }
    }

    function openFolders(urls)
    {
        control.urls = urls
    }
}

