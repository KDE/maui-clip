import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.maui.clip 1.0 as Clip

import ".."

Maui.AltBrowser
{
    id: control

    gridView.itemSize: Math.min(200, Math.max(100, Math.floor(width* 0.3)))
    gridView.itemHeight: gridView.itemSize + Maui.Style.rowHeight

    headBar.forceCenterMiddleContent: root.isWide
    holder.visible: _tagsList.count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.emoji: "qrc:/img/assets/tag.svg"
    holder.title: i18n("No Tags!")
    holder.body: i18n("Add a new tag to start organizing your video collection.")

    Binding on viewType
    {
        value: control.width < Maui.Style.units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid
        restoreMode: Binding.RestoreBinding
    }

    headBar.middleContent: Maui.SearchField
    {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignCenter
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter")
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: newTagDialog.open()
    }

    model: Maui.BaseModel
    {
        id: _collectionModel
        sortOrder: Qt.DescendingOrder
        sort: "modified"
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Clip.Tags
        {
            id: _tagsList
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        width: ListView.view.width
        label1.text: model.tag
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSize

        onClicked:
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                populateGrid(model.tag)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                populateGrid(model.tag)
            }
        }
    }

    gridDelegate: Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.CollageItem
        {
            width: control.gridView.itemSize - Maui.Style.space.medium
            height: control.gridView.itemHeight  - Maui.Style.space.medium

            isCurrentItem: parent.GridView.isCurrentItem

            images: model.preview.split(",")

            cb: function(url)
            {
                return "image://thumbnailer/"+url
            }

            template.label1.text: model.tag
            template.iconSource: model.icon
            template.iconVisible: true

            onClicked:
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    populateGrid(model.tag)
                }
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    populateGrid(model.tag)
                }
            }
        }

    }
}
