import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

import org.maui.clip 1.0 as Clip

import ".."

Maui.AltBrowser
{
    id: control

    gridView.itemSize: Math.min(260, Math.max(140, Math.floor(width* 0.3)))
    gridView.itemHeight: gridView.itemSize

    holder.visible: _tagsList.count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.emoji: "qrc:/img/assets/tag.svg"
    holder.title: i18n("No Tags!")
    holder.body: i18n("Add a new tag to start organizing your video collection.")

    Binding on viewType
    {
        value: control.width < Kirigami.Units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid
        restoreMode: Binding.RestoreBinding
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
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

    listDelegate: Maui.ListDelegate
    {
        width: ListView.view.width
        label: model.tag
        iconName: model.icon

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

    gridDelegate: Maui.CollageItem
    {
        id: _delegate
        property string tag : model.tag
        property url tagUrl : "tags:///"+model.tag

        height: control.gridView.cellHeight
        width: control.gridView.cellWidth

        isCurrentItem: GridView.isCurrentItem

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
